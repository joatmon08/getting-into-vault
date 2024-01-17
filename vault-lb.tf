resource "aws_lb" "vault_server" {
  name_prefix        = "vault-"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = local.vpc.public_subnets
  idle_timeout       = 60
}

resource "aws_lb_target_group" "vault_server" {
  name_prefix          = "vault-"
  port                 = 8200
  protocol             = "TLS"
  vpc_id               = local.vpc.vpc_id
  deregistration_delay = 30
  target_type          = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/v1/sys/health"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "vault_server" {
  load_balancer_arn = aws_lb.vault_server.arn
  port              = 8200
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.vault.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_server.arn
  }
}

resource "aws_security_group" "load_balancer" {
  name_prefix = "${var.name}-vault-server-"
  description = "Security group for Vault server load balancer"
  vpc_id      = local.vpc.vpc_id
}

resource "aws_security_group_rule" "load_balancer_allow_8200_from_external" {
  security_group_id = aws_security_group.load_balancer.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8200
  to_port           = 8200
  cidr_blocks       = var.allowed_traffic_cidr_blocks
  description       = "Allow HTTPS traffic to Vault servers"
}

resource "aws_security_group_rule" "load_balancer_allow_8200_from_servers" {
  security_group_id        = aws_security_group.load_balancer.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8200
  to_port                  = 8200
  source_security_group_id = aws_security_group.vault_server.id
  description              = "Allow Vault servers to connect to load balancer for auto-join"
}

resource "aws_security_group_rule" "load_balancer_allow_outbound" {
  security_group_id = aws_security_group.load_balancer.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow any outbound traffic."
}