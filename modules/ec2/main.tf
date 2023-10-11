# create vpc from module
module "vpc" {
  source               = "../vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

locals {
  ami           = "ami-08e5424edfe926b43"
  instance_type = "t2.micro"
  key_name      = "public-instance"
  user          = "ubuntu"
  private_key   = file("~/Downloads/public-instance.pem")
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
  ami                         = local.ami
  instance_type               = local.instance_type
  subnet_id                   = module.vpc.public_subnet_ids["Public-subnet-1"]
  security_groups             = [aws_security_group.public-sg.id]
  key_name                    = local.key_name
  associate_public_ip_address = true

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



resource "null_resource" "run_ansible" {
  triggers = {
    instance_id = aws_instance.nginx.id
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ~/Downloads/public-instance.pem ./ansible/nginx.yml"
  }
}

