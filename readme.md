# KTea Websites Infrastructure as Code (IaC)

This repository contains the Terraform configuration files for managing the infrastructure of KTea websites. It leverages Azure resources and follows best practices for Infrastructure as Code (IaC) to ensure consistency, scalability, and maintainability.

## Repository Structure

base
app
modules
examples

### Base
Provisions the following resources that can be used by all accounts

- Storage account
- Azure Container Registry

Does not use "backend" state.


## Key Features

- **Azure MySQL Flexible Server Module**: A reusable Terraform module for deploying and managing MySQL Flexible Servers in Azure.
- **Environment-Specific Configurations**: Supports staging environment configurations via `staging.auto.tfvars`.
- **Example Usage**: Provides a basic example in the `examples/basic` directory to demonstrate how to use the MySQL Flexible Server module.
- **Azure Best Practices**: Implements Azure best practices for resource management and security.

## Getting Started

### Prerequisites

Resource Providers for Container Apps

Microsoft.App
*Kubernets*


Subscription and resource gruop
Provision base
publish initial containers
provision databases, container instances and apps

As you add dbs, instances and apps, first add the continer image to the ACR (Azure Container Registry), update the Terraform, then plan and apply


- [Terraform](https://www.terraform.io/) installed on your local machine.
- Azure CLI installed and authenticated.
- Access to an Azure subscription.

### Container Images
In order to get around the chicken/egg problem of configuring Azure services dependent on container images, we assume that the local environment has access to initial container images.

Images can either be updated with Terraform in the future or by pushing images directly to Azure Container registry

Beware that re-running Terraform may cause your current image to be overwritten

### Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/your-org/ktea-websites-iac.git
   cd ktea-websites-iac
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

### Example Deployment

To deploy the MySQL Flexible Server using the example configuration:

1. Navigate to the example directory:
   ```bash
   cd examples/basic
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the configuration:
   ```bash
   terraform apply -var-file=staging.tfvars
   ```

## Modules

### MySQL Flexible Server Module

The `mysql-flexible-server` module is located in the `modules/mysql-flexible-server` directory. It supports the following features:
- Creating a MySQL Flexible Server.
- Configuring databases, firewall rules, and server settings.
- Outputting connection details.

Refer to the module's [README.md](modules/mysql-flexible-server/README.md) for detailed usage instructions.

## Variables

The repository uses variables defined in `variables.tf` and environment-specific `.tfvars` files. Key variables include:
- `project_name`: Name of the project.
- `environment_name`: Environment (e.g., staging, production).
- `mysql_server_name`: Name of the MySQL server.
- `mysql_administrator_login`: Administrator login for the MySQL server.
- `mysql_administrator_password`: Administrator password for the MySQL server.

## Outputs

The outputs of the Terraform configuration include:
- MySQL server name.
- Administrator login.
- Connection string.

## Notes

- Sensitive data such as passwords are excluded from version control using `.gitignore`.
- The repository uses a local backend for storing the Terraform state file.

## License

This project is licensed under the [Mozilla Public License Version 2.0](.terraform/providers/registry.terraform.io/hashicorp/azurerm/4.27.0/windows_amd64/LICENSE.txt).

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any improvements or bug fixes.
```