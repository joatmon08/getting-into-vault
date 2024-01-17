module "boundary_target_vault_servers" {
  source = "./boundary/targets"

  name                            = "vault-servers"
  description                     = "Vault server target"
  boundary_host_catalog_id        = data.terraform_remote_state.configure.outputs.boundary_target_vault_servers.host_catalog_id
  boundary_credentials_library_id = data.terraform_remote_state.configure.outputs.boundary_target_vault_servers.credentials_library_id

  host_ip_addresses = zipmap(aws_instance.vault_server.*.private_dns, aws_instance.vault_server.*.private_ip)
  # host_ip_addresses = {}

  boundary_scope_id          = data.terraform_remote_state.configure.outputs.boundary_scope_id
  boundary_storage_bucket_id = data.terraform_remote_state.configure.outputs.boundary_storage_bucket_id
}