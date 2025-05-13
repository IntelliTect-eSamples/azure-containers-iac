variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "ktea-sites"
}

variable "environment_name" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "staging"
}

variable "resource_group_name" {
  description = "The name of the resource group where the MySQL server will be created."
  type        = string
}

variable "region_name" {
  description = "The Azure region where the MySQL server will be created."
  type        = string
  default     = "westus2"
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}
