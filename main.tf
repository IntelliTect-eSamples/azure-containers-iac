
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
      
    },
    {
      app_name = "ktsite2"
      container_app_path = "c:/dev/webapp"
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



# publish an image to the container registry
resource "null_resource" "publish_image" {

  provisioner "local-exec" {
    command = <<EOT
      az acr login --name ${azurerm_container_registry.main.name}
      docker build --platform=linux/amd64 -t ${azurerm_container_registry.main.login_server}/${local.app_name}:latest ${local.container_app_path}/.
      docker push ${azurerm_container_registry.main.login_server}/${local.app_name}:latest
    EOT
  }

  depends_on = [azurerm_container_registry.main]
}


# image = "mcr.microsoft.com/azuredocs/aci-helloworld"
# create an azure container instance
resource "azurerm_container_group" "main" {
  name                = "${local.name_nodash}-aci"
  location            = var.region_name
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  image_registry_credential {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.admin_username
    password = azurerm_container_registry.main.admin_password
  }

  container {
    name   = "${local.name_nodash}-container"
    image  = "${azurerm_container_registry.main.login_server}/${local.app_name}:latest"
    cpu    = "0.5"
    memory = "1.5"


    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      MYSQL_HOST     = module.mysql_flexible_server.connection_string
      MYSQL_USER     = var.mysql_administrator_login
      MYSQL_PASSWORD = var.mysql_administrator_password
      MYSQL_DATABASE = local.databases[0].name
    }


  }

  diagnostics {
    log_analytics {
      workspace_id = azurerm_log_analytics_workspace.main.workspace_id
      workspace_key = azurerm_log_analytics_workspace.main.primary_shared_key
    }
  }

  tags = local.tags
}



# create an azure container app environment

# create an azure container app service

# create a storage account
resource "azurerm_storage_account" "main" {
  name                     = "${local.name_nodash}sa"
  resource_group_name      = var.resource_group_name
  location                 = var.region_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}


# azure front door







