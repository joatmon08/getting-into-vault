terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.79.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1.11"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.23.0"
    }
  }
}

provider "hcp" {}

provider "boundary" {
  addr                   = data.terraform_remote_state.setup.outputs.boundary.public_endpoint
  auth_method_login_name = data.terraform_remote_state.setup.outputs.boundary.username
  auth_method_password   = data.terraform_remote_state.setup.outputs.boundary.password
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = data.terraform_remote_state.setup.outputs.vault.id
}

provider "vault" {
  address   = data.terraform_remote_state.setup.outputs.vault.public_endpoint
  token     = hcp_vault_cluster_admin_token.cluster.token
  namespace = data.terraform_remote_state.setup.outputs.vault.namespace
}