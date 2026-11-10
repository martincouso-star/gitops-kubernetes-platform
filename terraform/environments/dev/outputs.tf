output "account_id" {
  description = "AWS account Terraform is running in."
  value       = data.aws_caller_identity.current.account_id
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded cluster CA certificate."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN."
  value       = module.eks.oidc_provider_arn
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by worker nodes."
  value       = module.vpc.private_subnets
}

output "external_dns_role_arn" {
  description = "IAM role ARN to annotate on the external-dns service account."
  value       = module.irsa.external_dns_role_arn
}

output "cert_manager_role_arn" {
  description = "IAM role ARN to annotate on the cert-manager service account."
  value       = module.irsa.cert_manager_role_arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN used by the EBS CSI add-on."
  value       = module.irsa.ebs_csi_role_arn
}

output "region" {
  description = "AWS region."
  value       = var.aws_region
}
