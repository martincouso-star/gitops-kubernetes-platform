output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "IDs of the private subnets."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnets
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets."
  value       = module.vpc.private_subnets_cidr_blocks
}
