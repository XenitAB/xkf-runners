variable "location" {
  type    = string
  default = "West Europe"
}

variable "resource_group" {
  type = string
}

variable "version" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
  default = ""
}

variable "use_azure_cli_auth" {
  type    = bool
  default = false
}

variable "image_name" {
  type = string
}

variable "gallery_name" {
  type = string
}

source "azure-arm" "agent" {
  use_azure_cli_auth                = var.use_azure_cli_auth
  subscription_id                   = var.subscription_id
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  image_publisher                   = "Canonical"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_sku                         = "22_04-lts"
  location                          = var.location
  managed_image_name                = "${var.image_name}-${var.version}"
  managed_image_resource_group_name = var.resource_group
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"

  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.resource_group
    gallery_name        = var.gallery_name
    image_name          = var.image_name
    image_version       = var.version
    replication_regions = [var.location]
  }
}

build {
  sources = ["source.azure-arm.agent"]
  name    = var.image_name

  provisioner "ansible" {
    use_proxy     = false
    playbook_file = "${path.root}/../../ansible/${var.image_name}/playbook.yaml"
  }

  # Standard Linux deprovisioning
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
