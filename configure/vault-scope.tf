## Set up credentials store to auto-inject SSH key

resource "boundary_credential_store_vault" "vault_nodes" {
  name        = "vault"
  description = "Vault credentials store for ${boundary_scope.vault.name}"
  address     = data.terraform_remote_state.setup.outputs.vault.public_endpoint
  token       = vault_token.boundary_worker_ssh.client_token
  namespace   = data.terraform_remote_state.setup.outputs.vault.namespace
  scope_id    = boundary_scope.vault.id
}

resource "boundary_credential_library_vault" "vault_nodes" {
  name                = "vault-ssh"
  description         = "Credential library for Vault node SSH"
  credential_store_id = boundary_credential_store_vault.vault_nodes.id
  path                = "${vault_kv_secret_v2.boundary_worker_keypair.mount}/data/${vault_kv_secret_v2.boundary_worker_keypair.name}"
  http_method         = "GET"
  credential_type     = "ssh_private_key"
}

resource "boundary_host_catalog_static" "vault_servers" {
  name        = "vault-servers"
  description = "Vault servers"
  scope_id    = boundary_scope.vault.id
}

## Set up individual logins

resource "random_password" "vault_operators" {
  for_each         = var.vault_operators
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "boundary_account_password" "vault_operators" {
  for_each       = var.vault_operators
  name           = each.key
  description    = "User account for ${each.key}"
  login_name     = lower(each.key)
  password       = random_password.vault_operators[each.key].result
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_user" "vault_operators" {
  for_each    = var.vault_operators
  name        = each.key
  description = "Vault operator: ${each.key}"
  account_ids = [boundary_account_password.vault_operators[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_group" "vault_operators" {
  name        = "vault-operators"
  description = "Vault operators team group"
  member_ids  = [for user in boundary_user.vault_operators : user.id]
  scope_id    = boundary_scope.vault.id
}

resource "boundary_role" "vault_operators" {
  name           = "vault-operators"
  description    = "Administrator role for ${boundary_scope.vault.name}"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.vault.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.vault_operators.id
  ]
}

