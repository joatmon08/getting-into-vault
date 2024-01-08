resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "getting-into-vault"
  description              = "Getting into Vault scope"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

## Set up Boundary scope for Vault nodes

resource "boundary_scope" "vault" {
  name                     = "vault"
  description              = "Vault infrastructure resources"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_auth_method" "password" {
  name        = boundary_scope.org.name
  description = "Password auth method for ${boundary_scope.org.name} org"
  type        = "password"
  scope_id    = boundary_scope.org.id
}
