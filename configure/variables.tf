data "terraform_remote_state" "setup" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"
    workspaces = {
      name = "getting-into-vault-setup"
    }
  }
}

variable "vault_operators" {
  type        = set(string)
  description = "List of Vault operators"
}