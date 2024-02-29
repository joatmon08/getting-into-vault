module "hcp" {
  source  = "joatmon08/hcp/aws"
  version = "5.0.2"

  hvn_region     = var.region
  hvn_name       = var.name
  hvn_cidr_block = "172.25.16.0/20"

  hcp_boundary_name = var.name
  hcp_boundary_tier = "Plus"

  hcp_vault_name            = var.name
  hcp_vault_public_endpoint = true

  hcp_consul_name            = var.name
  hcp_consul_public_endpoint = true
}

resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}

resource "aws_key_pair" "boundary" {
  key_name   = var.name
  public_key = trimspace(tls_private_key.boundary.public_key_openssh)
}

module "bucket" {
  depends_on = [module.hcp]

  source  = "joatmon08/hcp/aws//modules/boundary-bucket"
  version = "5.0.2"

  name = var.name
}

module "worker" {
  depends_on = [module.bucket]

  source  = "joatmon08/hcp/aws//modules/boundary-worker"
  version = "5.0.2"

  name                    = var.name
  boundary_addr           = module.hcp.boundary.public_endpoint
  vpc_id                  = module.vpc.vpc_id
  worker_public_subnet_id = module.vpc.public_subnets.0
  worker_keypair_name     = aws_key_pair.boundary.key_name
  boundary_username       = module.hcp.boundary.username
  boundary_password       = module.hcp.boundary.password
  additional_policy_arns  = [module.bucket.policy_arn]
}

resource "aws_security_group_rule" "allow_boundary_worker_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.worker.security_group_id
}

resource "aws_security_group_rule" "allow_boundary_worker_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["73.29.92.63/32"]
  security_group_id = module.worker.security_group_id
}