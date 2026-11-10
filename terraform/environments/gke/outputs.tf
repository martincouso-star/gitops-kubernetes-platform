output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.name
}

output "endpoint" {
  description = "GKE control plane endpoint."
  value       = module.gke.endpoint
}

output "ca_certificate" {
  description = "Base64-encoded cluster CA certificate."
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "region" {
  description = "Cluster region."
  value       = module.gke.region
}

output "network" {
  description = "VPC network name."
  value       = google_compute_network.this.name
}
