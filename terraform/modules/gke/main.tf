module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "47.0.0"

  project_id = var.project_id
  name       = var.name
  region     = var.region
  zones      = var.zones
  network    = var.network
  subnetwork = var.subnetwork

  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services

  enable_private_endpoint = false
  enable_private_nodes    = true
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  deletion_protection     = true

  master_authorized_networks = var.master_authorized_networks

  network_policy             = true
  horizontal_pod_autoscaling = true
  http_load_balancing        = true
  release_channel            = "REGULAR"
  remove_default_node_pool   = true
  enable_shielded_nodes      = true

  node_pools = [
    {
      name               = "default"
      machine_type       = var.node_machine_type
      min_count          = 1
      max_count          = 3
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 50
      disk_type          = "pd-balanced"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      initial_node_count = 1
      enable_gvnic       = true
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
