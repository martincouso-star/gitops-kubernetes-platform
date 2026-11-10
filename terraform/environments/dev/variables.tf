variable "aws_region" {
  description = "AWS region for the dev cluster."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "gitops-dev"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.36"
}

variable "vpc_cidr" {
  description = "CIDR for the dev VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "api_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS API. Replace the documentation range before apply. 0.0.0.0/0 is rejected."
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
  description = "Instance types for the dev managed node group."
  type        = list(string)
  default     = ["t3.large"]
}
