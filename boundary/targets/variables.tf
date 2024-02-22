variable "host_ip_addresses" {
  type        = map(string)
  description = "Name of host with IP address"
  default     = {}
}

variable "name" {
  type        = string
  description = "Name of Boundary host set and targets"
}

variable "description" {
  type        = string
  description = "Description of Boundary host set and targets"
}

variable "boundary_host_catalog_id" {
  type        = string
  description = "Host catalog ID in Boundary"
}

variable "boundary_scope_id" {
  type        = string
  description = "Boundary scope ID for targets"
}

variable "boundary_credentials_library_id" {
  type        = string
  description = "Boundary credentials library for targets"
}

variable "boundary_storage_bucket_id" {
  type        = string
  description = "Boundary storage bucket ID"
}
