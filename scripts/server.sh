#!/bin/bash

HOSTNAME=$(hostname)

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

apt update && sudo apt -y install vault

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
  node_id = "$${HOSTNAME}"

  # retry_join {
  #   leader_api_addr         = ""
  #   leader_ca_cert_file     = "/opt/vault/tls/ca.crt"
  # }
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