terraform {
  cloud {
    organization = "hashicorp-team-da-beta"

    workspaces {
      name = "getting-into-vault-setup"
    }
  }
}