packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  region         = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type  = "t3.xlarge"
  ssh_username   = "ubuntu"
  ami_name       = "llm-ubuntu-ami-{{timestamp}}"

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "gp3"
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    script = "llm.sh"
  }
}
