terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.79.0"
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

provider "hcp" {}