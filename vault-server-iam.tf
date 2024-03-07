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
    sid    = "VaultAutoJoin"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "VaultAutoUnsealKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.vault.arn
    ]
  }

  # statement {
  #   sid    = "VaultBackup"
  #   effect = "Allow"
  #   actions = [
  #     "s3:ListBucket",
  #     "s3:*Object"
  #   ]
  #   resources = [
  #     aws_s3_bucket.vault_backup.arn
  #   ]
  # }

  statement {
    sid    = "VaultAWSEC2AuthMethod"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "VaultAWSEC2AuthMethodAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.vault_server.arn
    ]
  }

  statement {
    sid    = "VaultEC2toAWSEKS"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
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
