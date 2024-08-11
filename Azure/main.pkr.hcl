packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}


# Define the source (Azure builder)
source "azure-arm" "for-packer" {
  // tenant_id = "****"
  // subscription_id = "****"
  // client_id = "****"
  // client_secret = "****"
  managed_image_name                = "Ubuntu-Packer-Base-{{timestamp}}"
  managed_image_resource_group_name = "Packer-Images"
  os_type                           = "Linux"
  location                          = "East US"
   image_publisher = "canonical"
   image_offer = "0001-com-ubuntu-server-jammy"
   image_sku = "22_04-lts"
  vm_size                           = "Standard_B1s"
  // use_azure_cli_auth                = true
  azure_tags = {
    Name = "Base-AMI"
    Description = "Created from Packer by KSR"
    Contents = "Nginx, Docker, Jenkins(8080)"
  }
}

build {
  name = "first-build"
  sources = [
    "source.azure-arm.for-packer"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
  provisioner "shell" {
    inline = [
      "curl https://get.docker.com | bash",
      "sudo usermod -a -G docker ubuntu",
      "sudo systemctl daemon-reload",
      "sudo service docker restart"
    ]
  }
}
