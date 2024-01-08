output "boundary" {
  value     = module.hcp.boundary
  sensitive = true
}

output "vault" {
  value     = module.hcp.vault
  sensitive = true
}

output "boundary_worker_keypair" {
  value = {
    name        = aws_key_pair.boundary.key_name
    private_key = base64encode(tls_private_key.boundary.private_key_openssh)
  }
  sensitive = true
}

output "vpc" {
  value = module.vpc
}

output "boundary_worker_security_group_id" {
  value = module.worker.security_group_id
}