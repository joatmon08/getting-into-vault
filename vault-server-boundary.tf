data "aws_instances" "vault_servers" {
  count      = var.server_desired_count == 0 ? 0 : 1
  depends_on = [aws_autoscaling_group.vault_server]
  instance_tags = {
    "Name" = local.vault
  }
}

module "boundary_target_vault_servers" {
  source = "./boundary/targets"

  name                            = "vault-servers"
  description                     = "Vault server target"
  boundary_host_catalog_id        = data.terraform_remote_state.configure.outputs.boundary_target_vault_servers.host_catalog_id
  boundary_credentials_library_id = data.terraform_remote_state.configure.outputs.boundary_target_vault_servers.credentials_library_id

  host_ip_addresses = try(zipmap(data.aws_instances.vault_servers.0.private_ips, data.aws_instances.vault_servers.0.private_ips), {})

  boundary_scope_id          = data.terraform_remote_state.configure.outputs.boundary_scope_id
  boundary_storage_bucket_id = data.terraform_remote_state.configure.outputs.boundary_storage_bucket_id
}