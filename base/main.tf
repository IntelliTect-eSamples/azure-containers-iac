locals {
  project     = var.project_name
  environment = "base"
  location    = var.region_name
  region      = var.region_name

  name        = trim(join("", [local.project, "-", local.environment]), "-")
  name_nodash = replace(local.name, "-", "")

  tags = {
    environment = var.environment_name
    project     = var.project_name
    cost_center = "IT"
  }

}


# create a storage account
resource "azurerm_storage_account" "main" {
  name                     = "${local.name_nodash}sa"
  resource_group_name      = var.resource_group_name
  location                 = var.region_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
