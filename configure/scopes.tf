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

resource "boundary_storage_bucket" "aws" {
  name        = "vault-server-session-recording"
  description = "Session records for Vault servers"
  scope_id    = boundary_scope.org.id
  plugin_name = "aws"
  bucket_name = data.terraform_remote_state.setup.outputs.boundary_bucket_name

  secrets_json = jsonencode({})

  attributes_json = jsonencode({
    "region"                      = var.region,
    "disable_credential_rotation" = true,
    "role_arn"                    = data.terraform_remote_state.setup.outputs.boundary_worker_role_arn,

  })

  worker_filter = "\"ingress\" in \"/tags/type\""

  lifecycle {
    ignore_changes = [internal_force_update]
  }
}