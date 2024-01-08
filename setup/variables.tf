variable "name" {
  type        = string
  description = "Name of resource"
  default     = "getting-into-vault"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
}