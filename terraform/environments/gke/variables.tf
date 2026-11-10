variable "project_id" {
  description = "GCP project id. This stack is optional and is not applied by CI."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name."
  type        = string
  default     = "gitops-gke"
}

variable "master_authorized_networks" {
  description = "CIDRs allowed to reach the GKE control plane. The default is documentation range TEST-NET-3."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "203.0.113.0/24"
      display_name = "replace-with-your-network"
    }
  ]
}
