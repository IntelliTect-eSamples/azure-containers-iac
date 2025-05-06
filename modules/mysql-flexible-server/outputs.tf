locals {
  server_name = azurerm_mysql_flexible_server.main.name
}

output "server_name" {
  value = local.server_name
}

output "administrator_login" {
  value = azurerm_mysql_flexible_server.main.administrator_login
}

output "connection_string" {
  value = "mysql://${azurerm_mysql_flexible_server.main.administrator_login}:${var.mysql_administrator_password}@${local.server_name}:3306/"
}
