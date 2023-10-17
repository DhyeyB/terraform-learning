output "my_vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "my_rds_endpoint" {
  value = module.rds.rds_endpoint
}