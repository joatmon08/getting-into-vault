resource "boundary_credential_library_vault" "database" {
  name                = "vault-database"
  description         = "Credential library for database static credentials"
  credential_store_id = boundary_credential_store_vault.vault_nodes.id
  path                = "${vault_kv_secret_v2.database.mount}/data/${vault_kv_secret_v2.database.name}"
  http_method         = "GET"
  credential_type     = "username_password"
}

resource "boundary_host_static" "database" {
  type            = "static"
  name            = "database"
  description     = "AWS RDS database"
  address         = data.terraform_remote_state.setup.outputs.database.url
  host_catalog_id = boundary_host_catalog_static.vault_servers.id
}

resource "boundary_host_set_static" "database" {
  type            = "static"
  name            = "database"
  description     = "AWS RDS database"
  host_catalog_id = boundary_host_catalog_static.vault_servers.id
  host_ids        = [boundary_host_static.database.id]
}

resource "boundary_target" "hosts" {
  type                     = "tcp"
  name                     = "database"
  description              = "psql access for database"
  scope_id                 = boundary_scope.vault.id
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  session_connection_limit = -1
  default_port             = 5432

  host_source_ids = [
    boundary_host_set_static.database.id
  ]

  brokered_credential_source_ids = [
    boundary_credential_library_vault.database.id
  ]
}