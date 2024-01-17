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

resource "aws_security_group_rule" "allow_load_balancer_to_vault_server" {
  type                     = "ingress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.load_balancer.id
  security_group_id        = aws_security_group.vault_server.id
}

resource "aws_security_group_rule" "allow_vault_servers_8200" {
  type                     = "ingress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vault_server.id
  security_group_id        = aws_security_group.vault_server.id
}

resource "aws_security_group_rule" "allow_vault_servers_8201" {
  type                     = "ingress"
  from_port                = 8201
  to_port                  = 8201
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vault_server.id
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