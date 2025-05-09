locals {
  project     = var.project_name
  environment = var.environment_name
  location    = var.region_name
  region      = var.region_name
  mysql_server_name = var.mysql_server_name

  name        = trim(join("", [local.project, "-", local.environment]), "-")
  name_nodash = replace(local.name, "-", "")

  mysql_server_fullname = join("-", [local.name, local.mysql_server_name])

  app_domain                     = "ktea.com"
  vnet_address_cidr              = "10.0.0.0/16"
  vnet_address_cidr_range        = "10.0.0.0/16"
  storage_account_sas_starttime  = timestamp() 
  storage_account_sas_expirytime = "2099-12-31T00:00:00Z"

  network_whitelist = [
    {
      name       = "office_ip_1"
      ip_address = "75.239.228.236"
    },
    {
      name       = "office_ip_2"
      ip_address = "50.212.205.194"
    },
    {
      name       = "allow_access_to_azure_services"
      ip_address = "0.0.0.0"
    }
  ]

  databases = [
    {
      name      = "mysqldb"
      charset   = "utf8"
      collation = "utf8_unicode_ci"
    },
    {
      name      = "mysqldb2"
      charset   = "utf8"
      collation = "utf8_unicode_ci"
    }  
  
  ]

  tags = {
    environment = var.environment_name
    project     = var.project_name
    cost_center = "IT"
  }

  webapps = [
    {
      app_name = "ktsite1"
      container_app_path = "c:/dev/webapp"
      db_name = "mysqldb1"
      
    },
    {
      app_name = "ktsite2"
      container_app_path = "c:/dev/webapp"
      db_name = "mysqldb2"
    }
  ]

}


# create a container registry
resource "azurerm_container_registry" "main" {
  name                = "${local.name_nodash}acr"
  resource_group_name = var.resource_group_name
  location            = var.region_name
  sku                 = "Standard"
  admin_enabled       = true

  tags = local.tags
}

# create log analytics workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.name_nodash}-law"
  location            = var.region_name
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

### per app

# create a mysql flexible server
module "mysql_flexible_server" {
  source              = "./modules/mysql-flexible-server"
  name                = local.mysql_server_fullname
  resource_group_name = var.resource_group_name
  region = var.region_name
  tags = local.tags
  mysql_administrator_login = var.mysql_administrator_login
  mysql_administrator_password = var.mysql_administrator_password
  mysql_sku_name      = var.mysql_sku_name
  mysql_sku_version   = var.mysql_sku_version
  network_whitelist   = local.network_whitelist
  databases           = local.databases
}

# Deploy container_instance for each entry in local.webapps
module "container_instances" {
  source = "./modules/container-instance"

  for_each = { for app in local.webapps : app.app_name => app }

  container_registry_name     = azurerm_container_registry.main.name
  container_registry_server   = azurerm_container_registry.main.login_server
  container_registry_username = azurerm_container_registry.main.admin_username
  container_registry_password = azurerm_container_registry.main.admin_password
  app_name                    = each.value.app_name
  container_app_path          = each.value.container_app_path
  resource_group_name         = var.resource_group_name
  region_name                 = var.region_name
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.main.workspace_id
  log_analytics_workspace_key = azurerm_log_analytics_workspace.main.primary_shared_key
  mysql_connection_string     = module.mysql_flexible_server.connection_string
  mysql_user                  = var.mysql_administrator_login
  mysql_password              = var.mysql_administrator_password
  mysql_database              = each.value.db_name
  tags                        = local.tags
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

resource "azurerm_storage_container" "container1" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}


# azure front door







