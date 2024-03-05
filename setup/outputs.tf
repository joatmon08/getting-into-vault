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

output "boundary_bucket_name" {
  value = module.bucket.bucket_name
}

output "boundary_worker_role_arn" {
  value = module.worker.role_arn
}

output "database" {
  value = {
    url      = aws_db_instance.database.address
    username = aws_db_instance.database.username
    password = aws_db_instance.database.password
    db_name  = aws_db_instance.database.db_name
  }
  sensitive = true
}

output "kubernetes" {
  value = {
    id                = module.eks.cluster_name
    endpoint          = module.eks.cluster_endpoint
    security_group_id = module.eks.node_security_group_id
  }
}