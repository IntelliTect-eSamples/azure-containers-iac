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
      db_name = "mysqldb1"
      
    },
    {
      app_name = "ktsite2"
      app_path = "c:/dev/webapp"
      db_name = "mysqldb2"
    }
  ]

  container_app  = {
    name = "ktsite3"
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
    type = "UserAssigned"
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


resource "null_resource" "publish_image" {
  triggers = {
      registry_name = azurerm_container_registry.main.name
      app_name = local.container_app.name

  }

  provisioner "local-exec" {
    command = <<EOT
      az acr login --name ${azurerm_container_registry.main.name}
      docker build --platform=linux/amd64 -t ${azurerm_container_registry.main.login_server}/${local.container_app.name}:latest ${local.container_app.app_path}/.
      docker push ${azurerm_container_registry.main.login_server}/${local.container_app.name}:latest
    EOT
  }
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

resource "azurerm_storage_container" "container1" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# create a container app environment
resource "azurerm_container_app_environment" "main" {
  name                = "${local.name_nodash}-app-env"
  resource_group_name = var.resource_group_name
  location            = var.region_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id


  tags = local.tags
}



# create a container app
resource "azurerm_container_app" "main" {
  name                = "${local.name_nodash}-containerapp"
  resource_group_name = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.main.id

  revision_mode = "Single"

  ingress {
    external_enabled = true
    allow_insecure_connections = true
    target_port = 80
    transport = "auto"
    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.name
    password_secret_name = "admin-password"
  }

  secret {
    name = "admin-password"
    value = azurerm_container_registry.main.admin_password
  }

  template {
    container {
      name   = "ktsite1"
      image  = "${azurerm_container_registry.main.login_server}/${local.container_app.name}:latest"
      cpu    = "0.5"
      memory = "1.0Gi"

      env {
        name  = "MYSQL_HOST"
        value = module.mysql_flexible_server.connection_string
      }
      env {
        name  = "MYSQL_USER"
        value = var.mysql_administrator_login
      }
      env {
        name  = "MYSQL_PASSWORD"
        value = var.mysql_administrator_password
      }
      env {
        name  = "MYSQL_DATABASE"
        value = "mysqldb3"
      }
    }

  }

  tags = local.tags
}


# create azure front door and link to container app
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "main-profile"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "example" {
  name                     = "example-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.example.id

  tags = {
    ENV = "example"
  }
}



resource "azurerm_front_door" "main" {
  name                = "${local.name_nodash}-frontdoor"
  resource_group_name = var.resource_group_name
  location            = var.region_name

  frontend_endpoint {
    name      = "frontend"
    host_name = "${local.name}.azurefd.net"
  }

  backend_pool {
    name = "backendpool"

    backend {
      host_header = "${azurerm_container_app.main.name}.azurefd.net"
      address    = "${azurerm_container_app.main.name}.azurefd.net"
      http_port  = 80
      https_port = 443
    }
  }

  routing_rule {
    name               = "routingrule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [azurerm_front_door.frontend_endpoint.name]
    backend_pool_id    = azurerm_front_door.backend_pool.id
  }

  tags = local.tags
}








