resource "null_resource" "publish_image" {
  # for each app in local.webapps

  triggers = {
      registry_name = azurerm_container_registry.main.name
      app_name = local.container_app.name

  }

  provisioner "local-exec" {
    command = <<EOT
      az acr login --name ${var.container_registry_name}
      docker build --platform=linux/amd64 -t ${var.container_registry_login_server}/${var.container_app_name}:latest ${var.container_app_path}/.
      docker push ${var.container_registry_login_server}/${var.container_app_name}:latest
    EOT
  }
}
