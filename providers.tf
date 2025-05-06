# Configure the Azure provider
terraform {

  # backend "azurerm" {}
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.27.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

