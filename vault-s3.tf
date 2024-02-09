resource "aws_s3_bucket" "vault_backup" {
  bucket        = var.name
  force_destroy = true
}