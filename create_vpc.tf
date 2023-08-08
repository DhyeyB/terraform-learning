# create vpc from module
module "vpc" {
  source               = "./modules/vpc/"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}





# resource "aws_eip" "nat" {
#   count = 2

#   domain = "vpc"
# }

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "my-vpc"
#   cidr = "10.0.0.0/16"

#   azs             = ["eu-west-2a", "eu-west-2b"]
#   private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
#   public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

#   enable_nat_gateway  = true
#   single_nat_gateway  = false
#   reuse_nat_ips       = true
#   external_nat_ip_ids = aws_eip.nat.*.id

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }
