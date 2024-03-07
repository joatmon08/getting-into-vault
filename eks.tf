data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_eks_node_groups" "cluster" {
  cluster_name = data.terraform_remote_state.setup.outputs.kubernetes.id
}

data "aws_eks_node_group" "cluster" {
  for_each = data.aws_eks_node_groups.cluster.names

  cluster_name    = data.terraform_remote_state.setup.outputs.kubernetes.id
  node_group_name = each.value
}

locals {
  node_groups = [for group in data.aws_eks_node_group.cluster : {
    rolearn  = group.node_role_arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes"]
  }]
}

module "eks_auth_configmap" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.3.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = concat(local.node_groups, [
    {
      rolearn  = data.aws_iam_session_context.current.issuer_arn
      username = "admin-dev"
      groups   = ["system:masters"]
    },
    {
      rolearn  = aws_iam_role.vault_server.arn
      username = "admin-vault"
      groups   = ["system:masters"]
    },
  ])
}