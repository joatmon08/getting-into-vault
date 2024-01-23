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

resource "aws_launch_template" "vault_server" {
  name_prefix            = "vault-server-"
  image_id               = data.aws_ami.ubuntu.image_id
  instance_type          = "t3.small"
  key_name               = local.keypair_name
  vpc_security_group_ids = [aws_security_group.vault_server.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.vault_server.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = local.tags
  }

  tag_specifications {
    resource_type = "volume"

    tags = local.tags
  }

  user_data = base64encode(templatefile("${path.module}/scripts/server.sh", {
    SERVER_CA             = tls_self_signed_cert.ca_cert.cert_pem
    SERVER_PUBLIC_KEY     = tls_locally_signed_cert.server_signed_cert.cert_pem
    SERVER_PRIVATE_KEY    = tls_private_key.server_key.private_key_pem
    REGION                = var.region
    TAG_KEY               = "Name"
    TAG_VALUE             = var.name
    LEADER_TLS_SERVERNAME = var.server_tls_servername
    KMS_KEY_ID            = aws_kms_key.vault.key_id
  }))
}

resource "aws_autoscaling_group" "vault_server" {
  name_prefix = "${var.name}-vault-server-"

  launch_template {
    id      = aws_launch_template.vault_server.id
    version = aws_launch_template.vault_server.latest_version
  }

  desired_capacity = var.server_desired_count
  min_size         = 1
  max_size         = var.server_desired_count + 1

  vpc_zone_identifier = local.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.vault_server.arn]

  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestLaunchTemplate"]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 1
      skip_matching          = true
    }
  }
}