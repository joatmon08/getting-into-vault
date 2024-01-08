output "vault_token" {
  value     = hcp_vault_cluster_admin_token.cluster.token
  sensitive = true
}

output "boundary_target_vault_servers" {
  value = {
    credentials_library_id = boundary_credential_library_vault.vault_nodes.id
    host_catalog_id        = boundary_host_catalog_static.vault_servers.id
  }
}

output "boundary_scope_id" {
  value = boundary_scope.vault.id
}

output "vault_operators" {
  value     = { for user, account in boundary_account_password.vault_operators : user => account.password }
  sensitive = true
}

output "vault_operators_auth_method_id" {
  value = boundary_auth_method.password.id
}