variable "cluster_name" {
  description = "EKS cluster name. Used as a prefix for IAM role names."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider."
  type        = string
}

variable "route53_zone_arns" {
  description = "Route 53 hosted zone ARNs that cert-manager and external-dns may change."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to IAM roles."
  type        = map(string)
  default     = {}
}
