locals {
  configurations = [
    {
      name  = "require_secure_transport"
      value = "OFF"
    }
  ]


}

resource "azurerm_mysql_flexible_server" "main" {
  name                = "${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.region

  administrator_login    = var.mysql_administrator_login
  administrator_password = var.mysql_administrator_password
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false
  sku_name                     = var.mysql_sku_name
  version                      = var.mysql_sku_version

  tags = var.tags

  storage {
    size_gb            = var.storage_size_gb
    auto_grow_enabled  = true
    io_scaling_enabled = true
  }

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
  }
}

resource "azurerm_mysql_flexible_server_configuration" "main" {
  for_each = { for c in local.configurations : c.name => c }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = each.value.value

  depends_on = [
    azurerm_mysql_flexible_server.main
  ]
}

resource "azurerm_mysql_flexible_server_firewall_rule" "main" {
  for_each = { for r in var.firewall_rules : r.name => r }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address

  depends_on = [
    azurerm_mysql_flexible_server.main
  ]
}

resource "azurerm_mysql_flexible_database" "main" {
  for_each = { for db in var.databases : db.name => db }

  name                = each.value.name
  server_name         = azurerm_mysql_flexible_server.main.name
  resource_group_name = var.resource_group_name
  collation           = each.value.collation
  charset             = each.value.charset

  depends_on = [
    azurerm_mysql_flexible_server.main
  ]
}