## Store SSH key for Boundary worker in HCP Vault

resource "vault_mount" "boundary_worker" {
  path        = "boundary/worker"
  type        = "kv"
  options     = { version = "2" }
  description = "Boundary worker tokens"
}

resource "vault_kv_secret_v2" "boundary_worker_keypair" {
  mount               = vault_mount.boundary_worker.path
  name                = "ssh"
  delete_all_versions = true
  data_json = jsonencode(
    {
      private_key = base64decode(data.terraform_remote_state.setup.outputs.boundary_worker_keypair.private_key)
      username    = "ubuntu"
    }
  )
}

data "vault_policy_document" "boundary_worker_ssh" {
  rule {
    path         = "${vault_kv_secret_v2.boundary_worker_keypair.mount}/data/${vault_kv_secret_v2.boundary_worker_keypair.name}"
    capabilities = ["read"]
    description  = "Get SSH keys for Boundary worker"
  }
}

resource "vault_policy" "boundary_credentials_store" {
  name   = "boundary-credentials-store"
  policy = <<EOT
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_policy" "boundary_worker_ssh" {
  name   = "boundary-worker-ssh"
  policy = data.vault_policy_document.boundary_worker_ssh.hcl
}

resource "vault_token" "boundary_worker_ssh" {
  policies          = [vault_policy.boundary_worker_ssh.name, vault_policy.boundary_credentials_store.name]
  no_default_policy = true
  no_parent         = true
  ttl               = "180d"
  explicit_max_ttl  = "365d"
  period            = "180d"
  renewable         = true
  num_uses          = 0
}