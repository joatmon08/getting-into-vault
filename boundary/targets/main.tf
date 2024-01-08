resource "boundary_host_static" "hosts" {
  for_each        = var.host_ip_addresses
  type            = "static"
  name            = each.key
  description     = "${var.description} at ${each.value}"
  address         = each.value
  host_catalog_id = var.boundary_host_catalog_id
}

resource "boundary_host_set_static" "hosts" {
  type            = "static"
  name            = var.name
  description     = var.description
  host_catalog_id = var.boundary_host_catalog_id
  host_ids        = [for host in boundary_host_static.hosts : host.id]
}

resource "boundary_target" "hosts" {
  type                     = "tcp"
  name                     = "${var.name}-ssh"
  description              = "SSH for ${var.description}"
  scope_id                 = var.boundary_scope_id
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  session_connection_limit = 3
  default_port             = 22
  host_source_ids = [
    boundary_host_set_static.hosts.id
  ]
  brokered_credential_source_ids = [
    var.boundary_credentials_library_id
  ]
}