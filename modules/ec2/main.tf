# create vpc from module
module "vpc" {
  source               = "../vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

locals {
  ami                = "ami-08e5424edfe926b43"
  instance_type      = "t2.micro"
  key_name           = "public-instance"
  user               = "ubuntu"
  private_key        = file("~/Downloads/public-instance.pem")
  instance_disk_size = 30
}


###############     Public EC2 Instance (Bation Host)     ###########
resource "aws_security_group" "public-sg" {
  name_prefix = "public-sg-"
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                     = local.ami
  instance_type           = local.instance_type
  subnet_id               = module.vpc.public_subnet_ids["Public-subnet-1"]
  security_groups         = [aws_security_group.public-sg.id]
  key_name                = local.key_name
  disable_api_termination = true
  #   associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = local.instance_disk_size
  }
  user_data = <<-EOF
    #!/bin/bash
      sudo apt-get -y update
      sudo adduser --disabled-password --gecos '' deploy
      sudo passwd -d deploy
      sudo usermod -aG sudo deploy
      sudo su deploy
      sudo mkdir -p /home/deploy/.ssh
      sudo mkdir -p /opt/edugem/apps
      sudo mkdir -p /opt/edugem/logs
      sudo mkdir -p /opt/edugem/scripts
      sudo mkdir -p /opt/edugem/data
      sudo chown -R deploy:deploy /home/deploy
      sudo chown -R deploy:deploy /opt/edugem
      sudo chown -R 775 /opt/edugem
      sudo apt-get install -y nginx
      sudo service apache2 stop
      sudo systemctl disable apache2
      sudo systemctl enable nginx
      sudo service nginx restart
      sudo apt-get install -y git
      sudo apt install -y postgresql postgresql-contrib
    EOF

  provisioner "remote-exec" {
    inline = ["echo 'wait untill ssh is ready'"]

    connection {
      type        = "ssh"
      user        = local.user
      private_key = local.private_key
      host        = aws_instance.nginx.public_ip
    }
  }
}

resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  #   tags = {
  #     Name = var.instance_name
  #   }
}

# Resource block for ec2 and eip association #
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.nginx.id
  allocation_id = aws_eip.elastic_ip.id
}


# resource "null_resource" "run_ansible" {
#   triggers = {
#     instance_id = aws_instance.nginx.id
#   }

#   provisioner "local-exec" {
#     command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ~/Downloads/public-instance.pem ./ansible/nginx.yml"
#   }
# }

