variable "name" {
  type        = string
  description = "Name of resource"
  default     = "getting-into-vault"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
}

data "terraform_remote_state" "setup" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"
    workspaces = {
      name = "getting-into-vault-setup"
    }
  }
}

data "terraform_remote_state" "configure" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"
    workspaces = {
      name = "getting-into-vault-configure"
    }
  }
}

locals {
  keypair_name = data.terraform_remote_state.setup.outputs.boundary_worker_keypair.name
  vpc          = data.terraform_remote_state.setup.outputs.vpc
}