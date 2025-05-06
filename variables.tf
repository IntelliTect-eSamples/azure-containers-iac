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

variable "mysql_server_name" {
  description = "The name of the MySQL server."
  type        = string
  default     = "my-mysql-server"
}

variable "mysql_administrator_login" {
  description = "The administrator login for the MySQL server."
  type        = string
  default     = "ktea-admin"
}

variable "mysql_administrator_password" {
  description = "The administrator password for the MySQL server."
  type        = string
}

variable "mysql_sku_name" {
  description = "The SKU name for the MySQL server."
  type        = string
}

variable "mysql_sku_version" {
  description = "The version of the MySQL server."
  type        = string
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
