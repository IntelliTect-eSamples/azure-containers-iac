
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
}

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


# create a container registry
resource "azurerm_container_registry" "main" {
  name                = "${local.name_nodash}acr"
  resource_group_name = var.resource_group_name
  location            = var.region_name
  sku                 = "Standard"
  admin_enabled       = true

  tags = local.tags
}




