locals {
  project           = var.project_name
  environment       = var.environment_name
  location          = var.region_name
  region            = var.region_name
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
    },
    {
      name      = "mysqldb3"
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
      app_path = "c:/dev/webapp"
      db_name  = "mysqldb1"

    },
    {
      app_name = "ktsite2"
      app_path = "c:/dev/webapp"
      db_name  = "mysqldb2"
    }
  ]

  container_app = {
    name     = "ktsite3"
    app_path = "c:/dev/webapp"
  }
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = var.resource_group_name
  location            = var.region_name

  name = "registry-uai"
}


# create a container registry
resource "azurerm_container_registry" "main" {
  name                = "${local.name_nodash}acr"
  resource_group_name = var.resource_group_name
  location            = var.region_name
  sku                 = "Standard"
  admin_enabled       = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

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
  source                       = "./modules/mysql-flexible-server"
  name                         = local.mysql_server_fullname
  resource_group_name          = var.resource_group_name
  region                       = var.region_name
  tags                         = local.tags
  mysql_administrator_login    = var.mysql_administrator_login
  mysql_administrator_password = var.mysql_administrator_password
  mysql_sku_name               = var.mysql_sku_name
  mysql_sku_version            = var.mysql_sku_version
  network_whitelist            = local.network_whitelist
  databases                    = local.databases
}


# Deploy container_instance for each entry in local.webapps
module "container_instance" {
  source = "./modules/container-instance"

  for_each = { for app in local.webapps : app.app_name => app }

  container_registry_name     = azurerm_container_registry.main.name
  container_registry_server   = azurerm_container_registry.main.login_server
  container_registry_username = azurerm_container_registry.main.admin_username
  container_registry_password = azurerm_container_registry.main.admin_password
  app_name                    = each.value.app_name
  container_app_path          = each.value.app_path
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

resource "azurerm_storage_container" "craft" {
  name                  = "craftcms"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# create an azure file share for container app storage
resource "azurerm_storage_share" "containerapp" {
  name                 = "containerapp-files"
  storage_account_id = azurerm_storage_account.main.id  
  quota                = 5
}

# create a container app environment
resource "azurerm_container_app_environment" "main" {
  name                       = "${local.name_nodash}-app-env"
  resource_group_name        = var.resource_group_name
  location                   = var.region_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = local.tags
}

# create container app environment storage
resource "azurerm_container_app_environment_storage" "main" {
  name                         = "azurefiles"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.main.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  share_name                   = azurerm_storage_share.containerapp.name
  access_mode                  = "ReadWrite"
}

# create a container app
resource "azurerm_container_app" "main" {
  name                         = "${local.name_nodash}-containerapp"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.main.id

  revision_mode = "Single"

  ingress {
    external_enabled           = true
    allow_insecure_connections = true
    target_port                = 80
    transport                  = "auto"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.name
    password_secret_name = "admin-password"
  }

  secret {
    name  = "admin-password"
    value = azurerm_container_registry.main.admin_password
  }

  template {
    container {
      name   = local.container_app.name
      image  = "${azurerm_container_registry.main.login_server}/${local.container_app.name}:latest"
      cpu    = "0.5"
      memory = "1.0Gi"

      volume_mounts {
        name = "appfiles"
        path = "/mnt/storage"
      }
    }

    volume {
      name         = "appfiles"
      storage_name = azurerm_container_app_environment_storage.main.name
      storage_type = "AzureFile"
    }
  }

  tags = local.tags
}


resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "${var.project_name}-frontdoor"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = local.tags
}

# create azure front door and link to container app
module "cdn_frontdoor_containerapp" {
  source      = "./modules/cdn_frontdoor"
  frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  app_name    = local.container_app.name
  app_fqdn    = azurerm_container_app.main.latest_revision_fqdn
  resource_group_name   = var.resource_group_name
  tags                  = local.tags
}

module "cdn_frontdoor_webapp" {
  for_each = module.container_instance

  source      = "./modules/cdn_frontdoor"
  frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  app_name    = each.value.container_group_name
  app_fqdn    = coalesce(each.value.container_group_fqdn, each.value.container_group_ip_address)
  resource_group_name   = var.resource_group_name
  tags                  = local.tags
}



