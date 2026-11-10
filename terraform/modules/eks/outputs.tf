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

output "cluster_version" {
  description = "Kubernetes version of the cluster."
  value       = module.eks.cluster_version
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider used for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "OIDC issuer host path, without the https scheme."
  value       = module.eks.oidc_provider
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS control plane."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Shared security group for managed nodes."
  value       = module.eks.node_security_group_id
}

output "kms_key_arn" {
  description = "KMS key used for Kubernetes secret encryption."
  value       = module.eks.kms_key_arn
}
