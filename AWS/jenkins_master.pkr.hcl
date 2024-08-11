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
  ami_name      = "Ubuntu-Packer-Jenkins-Master-{{timestamp}}"
  ami_description = "Created from Packer by KSR"
  instance_type = "t2.large"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.jammy_2204.id
  ssh_username  = "ubuntu"
  tags = {
    Name = "Jenkins-Master-AMI"
    Description = "Created from Packer by KSR"
    Contents = "Jenkins(8080), Java, Maven, JQ, Net-Tools, Docker, Terraform, Packer, Ansible, AWS CLI, Trivy"
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
      "sudo apt install openjdk-17-jdk -y",
      "sudo apt install -y maven jq net-tools unzip",
      "sudo java -version"
    ]
  }

  provisioner "shell" {
    inline = [
      "curl https://get.docker.com | sudo bash",
      "sudo usermod -a -G docker ubuntu",
      "sudo systemctl daemon-reload",
      "sudo service docker restart"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo wget https://releases.hashicorp.com/terraform/1.9.4/terraform_1.9.4_linux_amd64.zip",
      "sudo unzip *.zip",
      "sudo mv terraform /usr/local/bin/",
      "sudo rm -rf terraform*.zip",
      "sudo mv LICENSE.txt LICENSE.txt.tf",
      "sudo wget https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip",
      "sudo unzip *.zip",
      "sudo mv packer /usr/local/bin/",
      "sudo rm -rf packer*.zip",
      "sudo apt install software-properties-common -y",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo useradd -m ansibleadmin --shell /bin/bash",
      "sudo mkdir -p /home/ansibleadmin/.ssh",
      "sudo touch /home/ansibleadmin/.ssh/authorized_keys",
      "sudo usermod -aG sudo ansibleadmin",
      "echo 'ansibleadmin ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKvSz4MK0Iex5SgQu7MRBItNNP54/XD+tBR1Ntus8ycDcHXPa2kxRSfYoNOKE+D1MUuZXQMNUw0iTUjGD8BmMntexrvWcRHUjOMkN4py2EwH8bLdC+z3zMh3TMqPeCnsCGGoq2Diozgj/LViYQZ231Vfmmfu3V3hBcBpYQQAChOf8zWk5/l42QL6tdfg3uXX+pEc5wm6zhYT06g434mK9oZEOb2srHbDaBpdMM0yG83dmhZLkxJLIxkTBY4pBUsfgy/3l3PO95EFvkEzreOdVf+p3An1sVE1QRhIXY+IV/6C0EDazpzRoW8XLkp2T7hmnvtBwD6VdGmAf55xxgT1jl' | sudo tee /home/ansibleadmin/.ssh/authorized_keys"
    ]
  }
  
  provisioner "shell" {
    inline = [
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "wget https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb",
      "sudo dpkg -i trivy_0.18.3_Linux-64bit.deb"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]\" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install jenkins -y",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl status jenkins"
    ]
  }

}
