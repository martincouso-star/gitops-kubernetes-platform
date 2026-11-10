output "external_dns_role_arn" {
  description = "IAM role ARN for the external-dns service account."
  value       = module.external_dns.arn
}

output "external_dns_role_name" {
  description = "IAM role name for external-dns."
  value       = module.external_dns.name
}

output "cert_manager_role_arn" {
  description = "IAM role ARN for the cert-manager service account."
  value       = module.cert_manager.arn
}

output "cert_manager_role_name" {
  description = "IAM role name for cert-manager."
  value       = module.cert_manager.name
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI controller."
  value       = module.ebs_csi.arn
}

output "ebs_csi_role_name" {
  description = "IAM role name for the EBS CSI controller."
  value       = module.ebs_csi.name
}
