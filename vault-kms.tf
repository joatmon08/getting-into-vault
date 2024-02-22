resource "aws_kms_key" "vault" {
  description             = "Unseal keys for ${var.name}'s Vault server"
  deletion_window_in_days = 30
}