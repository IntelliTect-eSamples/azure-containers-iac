# Configure the Azure provider
terraform {

  backend "azurerm" {
    resource_group_name  = var.resource_group_name
    storage_account_name = azurerm_storage_account.main.name
    container_name       = azurerm_storage_container.tfstate.name
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.27.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
  }
}




