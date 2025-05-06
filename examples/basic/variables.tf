locals {
  mysql_administrator_login    = "admin_user"
  mysql_administrator_password = "P@ssw0rd!"
  mysql_sku_name              = "Standard_D2s_v3"
  mysql_sku_version           = "5.7"
  resource_group_name         = "my-resource-group"
  region                      = "westus2"
  name                        = "my-mysql-server"
}

variable "mysql_administrator_login" {
  description = "The administrator login for the MySQL server."
  type        = string
  default     = local.mysql_administrator_login
}

variable "mysql_administrator_password" {
  description = "The administrator password for the MySQL server."
  type        = string
  default     = local.mysql_administrator_password
}

variable "mysql_sku_name" {
  description = "The SKU name for the MySQL server."
  type        = string
  default     = local.mysql_sku_name
}

variable "mysql_sku_version" {
  description = "The version of the MySQL server."
  type        = string
  default     = local.mysql_sku_version
}

variable "resource_group_name" {
  description = "The name of the resource group where the MySQL server will be created."
  type        = string
  default     = local.resource_group_name
}

variable "region" {
  description = "The Azure region where the MySQL server will be created."
  type        = string
  default     = local.region
}

variable "name" {
  description = "The name of the MySQL server."
  type        = string
  default     = local.name
}