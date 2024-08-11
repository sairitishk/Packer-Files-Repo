packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  // access_key    = "" // use only if req.
  // secret_key    = ""
  profile = "default"
  ami_name      = "Ubuntu-Packer-Ansible-Client-{{timestamp}}"
  ami_description = "Created from Packer by KSR"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami = data.amazon-ami.jammy_2204.id
  ssh_username  = "ubuntu"
  tags = {
    Name = "Ansible-Client-AMI"
    Description = "Created from Packer by KSR"
    Contents = "No tools, just ansibleadmin user with k2 pub key"
  }
}

data "amazon-ami" "jammy_2204" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["amazon"]
  most_recent = true
  region      = "us-east-1"
}

build {
  name = "first-build"
  sources = [
    "source.amazon-ebs.ubuntu"
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
