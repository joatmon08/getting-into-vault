terraform {
  required_version = "~> 1.7.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
  }
}

locals {
  tags = {
    Owner   = var.owner
    Purpose = "Getting into Vault"
    Name    = var.name
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

provider "boundary" {
  addr                   = data.terraform_remote_state.setup.outputs.boundary.public_endpoint
  auth_method_login_name = data.terraform_remote_state.setup.outputs.boundary.username
  auth_method_password   = data.terraform_remote_state.setup.outputs.boundary.password
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.setup.outputs.kubernetes.id
}
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.setup.outputs.kubernetes.id
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.setup.outputs.kubernetes.id]
    command     = "aws"
  }
}