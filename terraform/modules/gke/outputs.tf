output "endpoint" {
  description = "GKE control plane endpoint."
  value       = module.gke.endpoint
}

output "ca_certificate" {
  description = "Base64-encoded cluster CA certificate."
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "name" {
  description = "GKE cluster name."
  value       = module.gke.name
}

output "region" {
  description = "Cluster region."
  value       = module.gke.region
}

output "service_account" {
  description = "Service account used by the node pool."
  value       = module.gke.service_account
}
