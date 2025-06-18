# KTEA Websites Infrastructure as Code (IaC)

This repository contains the Terraform configuration files for managing the infrastructure of KTea websites. It leverages Azure resources and follows best practices for Infrastructure as Code (IaC) to ensure consistency, scalability, and maintainability.

## Repository Structure

root module folder
base
modules
examples

### Base
Provisions the following resources that can be used by all accounts. The base configuration does not use Terraform backend state.

- Storage account
- Azure Container Registry (todo)

### modules
Terraform modules used to create reusable components for the infrastructure. Each module is self-contained and can be used independently or in combination with others.

### examples
Contains example configurations demonstrating how to use the modules defined in the `modules` directory. 


## Key Features

- **Azure MySQL Flexible Server Module**: A reusable Terraform module for deploying and managing MySQL Flexible Servers in Azure.
- **Environment-Specific Configurations**: Supports staging environment configurations via `<env>.auto.tfvars`.
- **Example Usage**: Provides a basic example in the `examples/basic` directory to demonstrate how to use the MySQL Flexible Server module.
- **Azure Best Practices**: Implements Azure best practices for resource management and security.

## Getting Started
1. Review pre-requisites
1. Run the base terraform to provision backend state
2. Build initial versions of site containers
3. Update main.tf and tfvars as needed for your environment

### Prerequisites

- [Terraform](https://www.terraform.io/) installed on your local machine.
- Azure CLI installed and authenticated.
- Access to an Azure subscription.

1. Azure Subscription
    - Identify existing or create new Azure subscription
    - Note Entra ID tenant associted with the subscription
1. Entra ID Groups
    - Create groups for each environment (staging, prod) in the subscription tentant
    - Add users responsible for managing resources in the environment to the group
    - Add the group as Contributor to the Resource Group
1. Resource Group for each environment
    - Resource groups are manually provisioned
    - Set the name of the group in the appropriate tfvars file (e.g., `staging.auto.tfvars`)
1. Resource Provider(s) for Container Apps
    - Microsoft.App

### Base Configuration
Provision base Terraform configuration from the base folder.

1. Review variable settings
1. Terraform init
1. Terrafrom plan
1. Terraform apply

### Container Images

This repository assumes that you have access to initial container images for the websites. The process for managing these images is as follows:
1. Build the container images locally or use pre-built images.
2. Push the images to Azure Container Registry (ACR) or another container registry.
3. Update the Terraform configuration to reference the container images in ACR.
4. Use Terraform to provision the necessary Azure resources, including databases, container instances, and apps.
5. Ensure that the container images are available in the ACR before running Terraform to avoid dependency issues.


As you add applications, first build and publish the container image to the ACR (Azure Container Registry), update the Terraform, then plan and apply

In order to get around the chicken/egg problem of configuring Azure services dependent on container images, the ACR is provisioned as part of the base and then the container images that are required are published prior to running the Terraform.

Images can either be updated with Terraform in the future or by pushing images directly to Azure Container registry

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

# Modules

## MySQL Flexible Server Module

The `mysql-flexible-server` module is located in the `modules/mysql-flexible-server` directory. It supports the following features:
- Creating a MySQL Flexible Server.
- Configuring databases, firewall rules, and server settings.
- Outputting connection details.

Refer to the module's [README.md](modules/mysql-flexible-server/README.md) for detailed usage instructions.


### Variables

The repository uses variables defined in `variables.tf` and environment-specific `.tfvars` files. Key variables include:
- `project_name`: Name of the project.
- `environment_name`: Environment (e.g., staging, production).
- `mysql_server_name`: Name of the MySQL server.
- `mysql_administrator_login`: Administrator login for the MySQL server.
- `mysql_administrator_password`: Administrator password for the MySQL server.

### Outputs

The outputs of the Terraform configuration include:
- MySQL server name.
- Administrator login.
- Connection string.

### Notes

- Sensitive data such as passwords are excluded from version control using `.gitignore`.

## Container Instance Module
The `container-instance` module is located in the `modules/container-instance` directory. It supports the following features:
- Creating Azure Container Instances.
- Configuring container images, environment variables, and resource limits. 
Refer to the module's [README.md](modules/container-instance/README.md) for detailed usage instructions.

## Frontdoor Module
The `frontdoor` module is located in the `modules/frontdoor` directory. It supports the following features:
- Creating Azure Front Door instances. 
- Configuring routing rules, backends, and health probes.
Refer to the module's [README.md](modules/frontdoor/README.md) for detailed usage instructions.




