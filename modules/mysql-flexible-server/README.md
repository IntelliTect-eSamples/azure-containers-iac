# MySQL Flexible Server Module

This module provides a reusable Terraform configuration for deploying an Azure MySQL Flexible Server. It includes the necessary resources for creating a MySQL server, configuring settings, setting up firewall rules, and creating databases.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "mysql_flexible_server" {
  source                    = "../modules/mysql-flexible-server"
  mysql_administrator_login = var.mysql_administrator_login
  mysql_administrator_password = var.mysql_administrator_password
  mysql_sku_name           = var.mysql_sku_name
  mysql_sku_version        = var.mysql_sku_version
  resource_group_name      = var.resource_group_name
  region                   = var.region
  network_whitelist        = var.network_whitelist
  databases                = var.databases
}
```

## Input Variables

The following input variables are required:

- `mysql_administrator_login`: The administrator login for the MySQL server.
- `mysql_administrator_password`: The password for the administrator login.
- `mysql_sku_name`: The SKU name for the MySQL server.
- `mysql_sku_version`: The version of the MySQL server.
- `resource_group_name`: The name of the resource group where the server will be created.
- `region`: The Azure region where the server will be deployed.
- `network_whitelist`: A list of IP addresses to whitelist for firewall rules.
- `databases`: A list of databases to create on the server.

## Outputs

This module will return the following outputs:

- `server_name`: The name of the MySQL server.
- `connection_string`: The connection string for the MySQL server.

## Examples

Refer to the `examples/basic` directory for a basic example of how to use this module.