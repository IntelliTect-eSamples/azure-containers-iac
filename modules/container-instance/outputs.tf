output "container_group_name" {
  value = azurerm_container_group.main.name
}
output "container_group_fqdn" {
  value = azurerm_container_group.main.fqdn
}
output "container_group_ip_address" {
  value = azurerm_container_group.main.ip_address
}