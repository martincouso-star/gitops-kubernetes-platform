variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version offered by Amazon EKS, such as 1.36."
  type        = string
}

variable "vpc_id" {
  description = "VPC that hosts the cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for worker nodes. Use private subnets."
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "Subnets for the EKS control plane ENIs. Use private subnets."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API has a public endpoint."
  type        = bool
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to call the public API endpoint. Ignored when public access is disabled."
  type        = list(string)
}

variable "deletion_protection" {
  description = "Whether the cluster refuses to be deleted until this is turned off."
  type        = bool
}

variable "log_retention_in_days" {
  description = "Retention for EKS control plane logs."
  type        = number
}

variable "node_instance_types" {
  description = "Instance types for the default managed node group."
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum size of the default managed node group."
  type        = number
}

variable "node_max_size" {
  description = "Maximum size of the default managed node group."
  type        = number
}

variable "node_desired_size" {
  description = "Desired size of the default managed node group at creation."
  type        = number
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT for the default managed node group."
  type        = string
  default     = "ON_DEMAND"
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}
