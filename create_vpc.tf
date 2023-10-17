terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

# create vpc from module
module "vpc" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "ec2" {
  source        = "./modules/ec2/"
  ingress_ports = var.ingress_ports
  depends_on    = [module.vpc]
}

module "rds" {
  source     = "./modules/rds/"
  depends_on = [module.vpc]
}