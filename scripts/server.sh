#!/bin/bash

instance_id=$( curl -Ss -H "X-aws-ec2-metadata-token: $imds_token" 169.254.169.254/latest/meta-data/instance-id )

apt update && apt -y install apt-transport-https ca-certificates curl jq unzip

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

apt update && sudo apt -y install vault

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update && sudo apt -y install kubectl

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

apt update && sudo apt -y install helm

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

mkdir -p /opt/vault.d
chown vault:vault -R /opt/vault.d
chmod g+rwx /opt/vault.d

cat > /opt/vault/tls/ca.crt <<- EOF
${SERVER_CA}
EOF

cat > /opt/vault/tls/tls.crt <<- EOF
${SERVER_PUBLIC_KEY}
EOF

cat > /opt/vault/tls/tls.key <<- EOF
${SERVER_PRIVATE_KEY}
EOF

cat > /etc/vault.d/vault.hcl <<- EOF
ui = true

cluster_addr = "https://{{ GetPrivateIP }}:8201"

api_addr = "https://{{ GetPrivateIP }}:8200"

disable_mlock = true

storage "raft" {
  path    = "/opt/vault.d/"
  node_id = "$${instance_id}"

  retry_join {
    auto_join               = "provider=aws region=${REGION} tag_key=${TAG_KEY} tag_value=${TAG_VALUE}"
    auto_join_scheme        = "https"
    leader_tls_servername   = "${LEADER_TLS_SERVERNAME}"
    leader_ca_cert_file     = "/opt/vault/tls/ca.crt"
    leader_client_cert_file = "/opt/vault/tls/tls.crt"
    leader_client_key_file  = "/opt/vault/tls/tls.key"
  }
}

seal "awskms" {
  region     = "${REGION}"
  kms_key_id = "${KMS_KEY_ID}"
}

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "/opt/vault/tls/tls.crt"
  tls_key_file       = "/opt/vault/tls/tls.key"
  tls_client_ca_file = "/opt/vault/tls/ca.crt"
}
EOF

systemctl enable vault
systemctl start vault

az=$( curl -Ss -H "X-aws-ec2-metadata-token: $imds_token" 169.254.169.254/latest/meta-data/placement/availability-zone )
if [[ $az == *"a" ]]; then
  export VAULT_CACERT=/opt/vault/tls/ca.crt
  vault operator init -format=json > /opt/vault/root.json

  cat > /opt/vault/vault.env <<- EOF
  export VAULT_CACERT=/opt/vault/tls/ca.crt
  export VAULT_TOKEN=$(cat /opt/vault/root.json | jq -r .root_token)
EOF
fi

mkdir -p /opt/vault/pki

cat > /opt/vault/pki/extfile.cnf <<- EOF
basicConstraints=CA:TRUE
authorityKeyIdentifier=keyid
EOF

cat > /opt/vault/pki/offline_ca.sh <<- EOF
export CERT_C="US"
export CERT_ST="California"
export CERT_L="San Francisco"

mkdir -p /opt/vault/pki/root
mkdir -p /opt/vault/pki/intermediate

openssl genrsa -des3 -out /opt/vault/pki/root/ca.key 4096
openssl req -new -x509 -days 3650 -key /opt/vault/pki/root/ca.key \
    -out /opt/vault/pki/root/ca.crt \
    -subj "/C=$${CERT_C}/ST=$${CERT_ST}/L=$${CERT_L}/O=HashiCorp/OU=Community/CN=Example Root CA"

### GET CSR FROM VAULT!

openssl x509 -req -in /opt/vault/pki/intermediate/ca.csr \
    -extfile /opt/vault/pki/extfile.cnf \
    -CA /opt/vault/pki/root/ca.crt -CAkey /opt/vault/pki/root/ca.key \
    -CAcreateserial -out /opt/vault/pki/intermediate/ca.crt -days 1096 -sha256
EOF