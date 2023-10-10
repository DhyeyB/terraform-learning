# create vpc from module
module "vpc" {
  source               = "./modules/vpc/"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}


###############     Public EC2 Instance (Bation Host)     ###########
resource "aws_security_group" "public-sg" {
  name_prefix = "public-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "ami-08e5424edfe926b43"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnet_ids["Public-subnet-1"]
  security_groups             = [aws_security_group.public-sg.id]
  key_name                    = "public-instance"
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = ["echo 'wait untill ssh is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/public-instance.pem")
      host        = aws_instance.nginx.public_ip
    }
  }

  # provisioner "local-exec" {
  #   command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ${"~/Downloads/public-instance.pem"} ./ansible/nginx.yml"
  # }
}



resource "null_resource" "run_ansible" {
  triggers = {
    instance_id = aws_instance.nginx.id
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ~/Downloads/public-instance.pem ./ansible/nginx.yml"
  }
}

