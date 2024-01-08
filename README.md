# getting-into-vault

This is a repository for the live stream, "Getting into Vault".

The root part of this repository contains configuration to set up the foundation
of infrastructure resources on AWS. Reproducing the entire setup requires...

- HCP Boundary
- HCP Vault (for SSH key)
- Terraform

## Student Setup

### Prerequisites

- [Boundary](https://developer.hashicorp.com/boundary/install)
- [Vault](https://developer.hashicorp.com/vault/install)

### Usage

- Log into Boundary.
  ```
  boundary authenticate password
  ```

- SSH into EC2 instances
  ```
  boundary connect ssh -target-name vault-servers-ssh -target-scope-name vault
  ```