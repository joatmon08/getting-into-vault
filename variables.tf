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

variable "server_desired_count" {
  type        = number
  description = "Desired number of Vault servers"
  default     = 3
}

variable "allowed_traffic_cidr_blocks" {
  type        = list(string)
  description = "Allowed traffic CIDR blocks to Vault server load balancer"
  default     = ["0.0.0.0/0"]
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