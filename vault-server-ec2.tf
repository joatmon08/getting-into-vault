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
    # for injecting variables
  }))
}

resource "aws_autoscaling_group" "vault_server" {
  name_prefix = "${var.name}-vault-server-"

  launch_template {
    id      = aws_launch_template.vault_server.id
    version = aws_launch_template.vault_server.latest_version
  }

  desired_capacity = 3
  min_size         = 1
  max_size         = 3

  vpc_zone_identifier = local.vpc.private_subnets

  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestLaunchTemplate"]
  wait_for_capacity_timeout = 0

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]
}