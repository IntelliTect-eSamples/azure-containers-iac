
# add output for the storage account name
output "storage_account_name" {
  value = azurerm_storage_account.main.name
}
output "storage_account_id" {
  value = azurerm_storage_account.main.id
}
