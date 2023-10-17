data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "${path.module}/../../terraform.tfstate"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "rds-sg-"
  vpc_id      = data.terraform_remote_state.vpc.outputs.my_vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "my-db-subnet-group"
  description = "My DB subnet group"
  subnet_ids  = values(data.terraform_remote_state.vpc.outputs.vpc_public_subnet_ids)
}

resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  db_name                = "my_db"
  instance_class         = "db.t2.micro"
  username               = "dbuser"
  password               = "dbpassword"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}
