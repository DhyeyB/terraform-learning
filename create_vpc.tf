# create vpc from module
module "ec2" {
  source        = "./modules/ec2/"
  ingress_ports = var.ingress_ports
}
