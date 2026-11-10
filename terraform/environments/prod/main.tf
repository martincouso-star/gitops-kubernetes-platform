data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Project     = "gitops-kubernetes-platform"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                       = "${var.cluster_name}-vpc"
  cidr                       = var.vpc_cidr
  azs                        = local.azs
  private_subnets            = [for idx in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, idx)]
  public_subnets             = [for idx in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, idx + 8)]
  single_nat_gateway         = false
  flow_log_retention_in_days = 90
  tags                       = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name                 = var.cluster_name
  kubernetes_version           = var.kubernetes_version
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = module.vpc.private_subnets
  control_plane_subnet_ids     = module.vpc.private_subnets
  endpoint_public_access       = false
  endpoint_public_access_cidrs = var.api_access_cidrs
  deletion_protection          = true
  log_retention_in_days        = 90
  node_instance_types          = var.node_instance_types
  node_min_size                = 2
  node_max_size                = 6
  node_desired_size            = 3
  tags                         = local.tags
}

module "irsa" {
  source = "../../modules/irsa"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  route53_zone_arns = var.route53_zone_arns
  tags              = local.tags

  depends_on = [module.eks]
}
