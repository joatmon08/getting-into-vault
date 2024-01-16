resource "aws_iam_role" "vault_server" {
  name_prefix        = "${var.name}-vault-server-"
  assume_role_policy = data.aws_iam_policy_document.instance_trust_policy.json
}

data "aws_iam_policy_document" "instance_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "instance_permissions_policy" {
  statement {
    sid    = "DescribeInstances"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "vault_server" {
  name_prefix = "${var.name}-vault-server-"
  role        = aws_iam_role.vault_server.id
  policy      = data.aws_iam_policy_document.instance_permissions_policy.json
}

resource "aws_iam_instance_profile" "vault_server" {
  name_prefix = "${var.name}-vault-server-"
  role        = aws_iam_role.vault_server.id
}