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
  ami_name      = "Ubuntu-Packer-Base-{{timestamp}}"
  ami_description = "Created from Packer by KSR"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.jammy_2204.id
  ssh_username  = "ubuntu"
  tags = {
    Name = "Base-AMI"
    Description = "Created from Packer by KSR"
    Contents = "Nginx, Docker, Jenkins(8080)"
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
