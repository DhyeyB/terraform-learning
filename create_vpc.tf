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
}

resource "aws_instance" "punlic-instance" {
  ami           = "ami-08e5424edfe926b43"
  instance_type = "t2.micro"
  # subnet_id       = "$(vpc.aws_subnet.public_subnet.id)"
  subnet_id                   = module.vpc.public_subnet_ids["Public-subnet-1"]
  security_groups             = [aws_security_group.public-sg.id]
  key_name                    = "public-instance"
  associate_public_ip_address = true
}


###############     Private EC2 Instance      ###########
resource "aws_security_group" "private-sg" {
  name_prefix = "private-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public-sg.id]
  }
}

resource "aws_instance" "private-instance" {
  ami                         = "ami-08e5424edfe926b43"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnet_ids["Private-subnet-1"]
  security_groups             = [aws_security_group.private-sg.id]
  key_name                    = "private-instance"
  associate_public_ip_address = true
}