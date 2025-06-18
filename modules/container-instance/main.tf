resource "azurerm_container_group" "main" {
  name                = "${var.app_name}-aci"
  location            = var.region_name
  resource_group_name = var.resource_group_name
  dns_name_label      = var.app_name
  os_type             = "Linux"
  ip_address_type     = "Public"

  image_registry_credential {
    server   = var.container_registry_server
    username = var.container_registry_username
    password = var.container_registry_password
  }

  container {
    name   = "${var.app_name}-container"
    image  = "${var.container_registry_server}/${var.app_name}:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      MYSQL_HOST     = var.mysql_connection_string
      MYSQL_USER     = var.mysql_user
      MYSQL_PASSWORD = var.mysql_password
      MYSQL_DATABASE = var.mysql_database
    }

  }

  diagnostics {
    log_analytics {
      workspace_id  = var.log_analytics_workspace_id
      workspace_key = var.log_analytics_workspace_key
    }
  }

  tags = var.tags
}
