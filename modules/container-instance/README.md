# Container Instance Module

This module provisions Azure Container Instances (ACI) for deploying containerized applications. It integrates with Azure Container Registry (ACR) and supports logging via Azure Log Analytics.

## Features

- Deploys container instances for specified applications.
- Configures container instances to pull images from Azure Container Registry.
- Supports environment-specific configurations.
- Integrates with Azure Log Analytics for monitoring and diagnostics.
- Configures MySQL connection strings for applications requiring database access.

## Inputs

- `container_registry_name`: Name of the Azure Container Registry.
- `container_registry_server`: Login server URL of the Azure Container Registry.
- `container_registry_username`: Username for the Azure Container Registry.
- `container_registry_password`: Password for the Azure Container Registry.
- `app_name`: Name of the application.
- `container_app_path`: Path to the containerized application.
- `resource_group_name`: Name of the Azure Resource Group.
- `region_name`: Azure region for the container instance.
- `log_analytics_workspace_id`: ID of the Azure Log Analytics Workspace.
- `log_analytics_workspace_key`: Key for the Azure Log Analytics Workspace.
- `mysql_connection_string`: Connection string for the MySQL database.
- `mysql_user`: MySQL administrator username.
- `mysql_password`: MySQL administrator password.
- `mysql_database`: Name of the MySQL database.
- `tags`: Tags to apply to the resources.

## Outputs

- `container_fqdn`: Fully qualified domain name (FQDN) of the deployed container instance.

## Usage

```terraform
module "container_instance" {
  source = "./modules/container-instance"

  container_registry_name     = "myacr"
  container_registry_server   = "myacr.azurecr.io"
  container_registry_username = "myacrusername"
  container_registry_password = "myacrpassword"
  app_name                    = "myapp"
  container_app_path          = "/path/to/app"
  resource_group_name         = "my-resource-group"
  region_name                 = "eastus"
  log_analytics_workspace_id  = "workspace-id"
  log_analytics_workspace_key = "workspace-key"
  mysql_connection_string     = "mysql-connection-string"
  mysql_user                  = "admin"
  mysql_password              = "password"
  mysql_database              = "mydatabase"
  tags                        = {
    environment = "staging"
    project     = "ktea"
  }
}
```

## Notes

- Ensure the container image is available in the Azure Container Registry before deploying the container instance.
- Use Azure Log Analytics to monitor and troubleshoot container instances.
