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

resource "aws_security_group" "vault_server" {
  name_prefix = "vault-server-"
  description = "Security group for Vault servers"
  vpc_id      = local.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_boundary_worker_to_vault_server" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.setup.outputs.boundary_worker_security_group_id
  security_group_id        = aws_security_group.vault_server.id
}

resource "aws_security_group_rule" "allow_boundary_worker_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vault_server.id
}

resource "aws_instance" "vault_server" {
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = "t3.small"
  key_name               = local.keypair_name
  vpc_security_group_ids = [aws_security_group.vault_server.id]
  subnet_id              = local.vpc.private_subnets.0

  user_data = base64encode(templatefile("${path.module}/scripts/server.sh", {
    # for injecting variables
  }))
}

module "boundary_target_vault_servers" {
  source = "./boundary/targets"

  name                            = "vault-servers"
  description                     = "Vault server target"
  boundary_host_catalog_id        = data.terraform_remote_state.configure.outputs.boundary_target_vault_servers.host_catalog_id
  boundary_credentials_library_id = data.terraform_remote_state.configure.outputs.boundary_target_vault_servers.credentials_library_id

  host_ip_addresses = {
    vault-server-0 = aws_instance.vault_server.private_ip
  }

  boundary_scope_id          = data.terraform_remote_state.configure.outputs.boundary_scope_id
  boundary_storage_bucket_id = data.terraform_remote_state.configure.outputs.boundary_storage_bucket_id
}