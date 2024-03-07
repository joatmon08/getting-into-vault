output "vault_endpoint" {
  value = "https://${aws_lb.vault_server.dns_name}:8200"
}