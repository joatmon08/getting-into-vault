data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [
    "099720109477"
  ]
}

locals {
  server_ips = [for i in local.vpc.private_subnets_cidr_blocks : cidrhost(i, 250)]
}

resource "aws_instance" "vault_server" {
  count = var.server_desired_count

  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.vault_server.id]
  subnet_id              = local.vpc.private_subnets[count.index]
  key_name               = local.keypair_name

  private_ip = local.server_ips[count.index]

  iam_instance_profile = aws_iam_instance_profile.vault_server.name

  user_data = base64encode(templatefile("${path.module}/scripts/server.sh", {
    SERVER_CA          = tls_self_signed_cert.ca_cert.cert_pem
    SERVER_PUBLIC_KEY  = tls_locally_signed_cert.server_signed_cert.cert_pem
    SERVER_PRIVATE_KEY = tls_private_key.server_key.private_key_pem
  }))
}