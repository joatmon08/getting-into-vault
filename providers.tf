terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1.11"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner   = var.owner
      Purpose = "Getting into Vault"
    }
  }
}

provider "boundary" {
  addr                   = data.terraform_remote_state.setup.outputs.boundary.public_endpoint
  auth_method_login_name = data.terraform_remote_state.setup.outputs.boundary.username
  auth_method_password   = data.terraform_remote_state.setup.outputs.boundary.password
}