variable "container_registry_name" {}
variable "container_registry_server" {}
variable "container_registry_username" {}
variable "container_registry_password" {}
variable "app_name" {}
variable "container_app_path" {}
variable "resource_group_name" {}
variable "region_name" {}
variable "log_analytics_workspace_id" {}
variable "log_analytics_workspace_key" {}
variable "mysql_connection_string" {}
variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {}
variable "tags" {
  type = map(string)
}
