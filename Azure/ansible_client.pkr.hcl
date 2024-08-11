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
      "sudo useradd -m ansibleadmin --shell /bin/bash",
      "sudo mkdir -p /home/ansibleadmin/.ssh",
      "sudo touch /home/ansibleadmin/.ssh/authorized_keys",
      "sudo usermod -aG sudo ansibleadmin",
      "echo 'ansibleadmin ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKvSz4MK0Iex5SgQu7MRBItNNP54/XD+tBR1Ntus8ycDcHXPa2kxRSfYoNOKE+D1MUuZXQMNUw0iTUjGD8BmMntexrvWcRHUjOMkN4py2EwH8bLdC+z3zMh3TMqPeCnsCGGoq2Diozgj/LViYQZ231Vfmmfu3V3hBcBpYQQAChOf8zWk5/l42QL6tdfg3uXX+pEc5wm6zhYT06g434mK9oZEOb2srHbDaBpdMM0yG83dmhZLkxJLIxkTBY4pBUsfgy/3l3PO95EFvkEzreOdVf+p3An1sVE1QRhIXY+IV/6C0EDazpzRoW8XLkp2T7hmnvtBwD6VdGmAf55xxgT1jl ritishk2' | sudo tee /home/ansibleadmin/.ssh/authorized_keys"
    ]
  }
}
