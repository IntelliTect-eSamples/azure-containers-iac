locals {
  mysql_server_name = "mysql-${var.name}"
}

module "mysql_flexible_server" {
  source              = "../../modules/mysql-flexible-server"
  name                = local.mysql_server_name
  resource_group_name = var.resource_group_name
  location            = var.region
  mysql_administrator_login = var.mysql_administrator_login
  mysql_administrator_password = var.mysql_administrator_password
  mysql_sku_name      = var.mysql_sku_name
  mysql_sku_version   = var.mysql_sku_version
  network_whitelist   = var.network_whitelist
  databases           = var.databases
}

output "mysql_server_name" {
  value = module.mysql_flexible_server.mysql_server_name
}