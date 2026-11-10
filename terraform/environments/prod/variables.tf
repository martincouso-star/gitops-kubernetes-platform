variable "aws_region" {
  description = "AWS region for the prod cluster."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "gitops-prod"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.36"
}

variable "vpc_cidr" {
  description = "CIDR for the prod VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "api_access_cidrs" {
  description = "CIDRs that would be allowed if the public API endpoint is later enabled. The prod cluster keeps the public endpoint off."
  type        = list(string)

  validation {
    condition     = length(var.api_access_cidrs) > 0 && alltrue([for cidr in var.api_access_cidrs : cidr != "0.0.0.0/0"])
    error_message = "api_access_cidrs must be non-empty and must not contain 0.0.0.0/0."
  }
}

variable "route53_zone_arns" {
  description = "Route 53 hosted zone ARNs for external-dns and cert-manager. Replace the placeholder before apply."
  type        = list(string)

  validation {
    condition     = length(var.route53_zone_arns) > 0
    error_message = "Provide at least one Route 53 hosted zone ARN."
  }
}

variable "node_instance_types" {
  description = "Instance types for the prod managed node group."
  type        = list(string)
  default     = ["m6i.large"]
}
