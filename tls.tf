# Root CA
resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048 # must be 2048 to work with ACM
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem   = tls_private_key.ca_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "Vault Server CA"
    organization = "HashiCorp Inc."
  }

  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]
}

# Server Certificate
resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 2048 # must be 2048 to work with ACM
}

## Public Server Cert
resource "tls_cert_request" "server_cert" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name  = "server.vault"
    organization = "HashiCorp Inc."
  }

  dns_names = [
    "server.vault",
    "localhost"
  ]

  ip_addresses = concat(["127.0.0.1"], local.server_ips)
}

## Signed Public Server Certificate
resource "tls_locally_signed_cert" "server_signed_cert" {
  cert_request_pem = tls_cert_request.server_cert.cert_request_pem

  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  allowed_uses = [
    "digital_signature",
    "key_encipherment"
  ]

  validity_period_hours = 8760
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.server_key.private_key_pem
  certificate_body = tls_locally_signed_cert.server_signed_cert.cert_pem
  certificate_chain = format("%s\n%s",
    tls_locally_signed_cert.server_signed_cert.cert_pem,
    tls_self_signed_cert.ca_cert.cert_pem
  )
}