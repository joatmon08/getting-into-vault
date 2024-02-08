resource "boundary_host_catalog_static" "vault_servers_green" {
  name        = "vault-servers-green"
  description = "Vault servers (Green deployment)"
  scope_id    = boundary_scope.vault.id
}