variable "project_id" {
  description = "GCP project that hosts the cluster."
  type        = string
}

variable "name" {
  description = "GKE cluster name."
  type        = string
}

variable "region" {
  description = "Region for the regional cluster."
  type        = string
}

variable "zones" {
  description = "Zones used by the node pool."
  type        = list(string)
}

variable "network" {
  description = "VPC network name."
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name."
  type        = string
}

variable "ip_range_pods" {
  description = "Secondary range name used for pod IPs."
  type        = string
}

variable "ip_range_services" {
  description = "Secondary range name used for service IPs."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "RFC1918 /28 for the control plane."
  type        = string
}

variable "master_authorized_networks" {
  description = "CIDRs allowed to reach the control plane endpoint."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "node_machine_type" {
  description = "Machine type for the default node pool."
  type        = string
  default     = "e2-standard-2"
}
