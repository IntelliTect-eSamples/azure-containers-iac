variable "name" {
  description = "The name of the MySQL Flexible Server."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the MySQL Flexible Server will be created."
  type        = string
}

variable "region" {
  description = "The Azure region where the MySQL Flexible Server will be deployed."
  type        = string
}

variable "mysql_administrator_login" {
  description = "The administrator login for the MySQL server."
  type        = string
}

variable "mysql_administrator_password" {
  description = "The administrator password for the MySQL server."
  type        = string
  sensitive   = true
}

variable "mysql_sku_name" {
  description = "The SKU name for the MySQL server."
  type        = string
}

variable "mysql_sku_version" {
  description = "The version of the MySQL server."
  type        = string
}

variable "network_whitelist" {
  description = "A list of IP addresses to whitelist for the MySQL server."
  type        = list(object({
    name      = string
    ip_address = string
  }))
}

variable "databases" {
  description = "A list of databases to create on the MySQL server."
  type        = list(object({
    name      = string
    charset   = string
    collation = string
  }))
  default     = [
    {
      name      = "mysqldb"
      charset   = "utf8mb4"
      collation = "utf8mb4_general_ci"
    }
  ]
}

variable "firewall_rules" {
  description = "A list of firewall rules to apply to the MySQL server."
  type        = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default     = [
    {
      name             = "AllowAzureServices"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "AllowLocalNetwork"
      start_ip_address = "192.168.0.1"
      end_ip_address   = "192.168.0.255"
    }
  ]
}

variable "tags" {
  description = "A map of tags to assign to the MySQL server."
  type        = map(string)
}


variable "storage_size_gb" {
  description = "The size of the storage in GB for the MySQL Flexible Server."
  type        = number
  default     = 32
}