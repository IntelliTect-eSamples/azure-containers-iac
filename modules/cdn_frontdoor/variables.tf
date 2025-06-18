variable "frontdoor_profile_id" {}
variable "app_name" {}
variable "app_fqdn" {}
variable "resource_group_name" {}
variable "tags" {}
variable "supported_protocols" {
  type    = list(string)
  default = ["Http", "Https"]
}
variable "https_redirect_enabled" {
  type    = bool
  default = true
}
