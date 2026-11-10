locals {
  pods_range_name     = "pods"
  services_range_name = "services"
  zones               = ["${var.region}-a", "${var.region}-b", "${var.region}-c"]
}

resource "google_project_service" "required" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "this" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  depends_on = [google_project_service.required]
}

resource "google_compute_subnetwork" "nodes" {
  name                     = "${var.cluster_name}-nodes"
  ip_cidr_range            = "10.20.0.0/20"
  region                   = var.region
  network                  = google_compute_network.this.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.pods_range_name
    ip_cidr_range = "10.40.0.0/14"
  }

  secondary_ip_range {
    range_name    = local.services_range_name
    ip_cidr_range = "10.44.0.0/20"
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "baseline_deny_ingress" {
  name     = "${var.cluster_name}-deny-ingress"
  network  = google_compute_network.this.name
  priority = 65534

  direction = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "this" {
  name    = "${var.cluster_name}-router"
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

module "gke" {
  source = "../../modules/gke"

  project_id                 = var.project_id
  name                       = var.cluster_name
  region                     = var.region
  zones                      = local.zones
  network                    = google_compute_network.this.name
  subnetwork                 = google_compute_subnetwork.nodes.name
  ip_range_pods              = local.pods_range_name
  ip_range_services          = local.services_range_name
  master_ipv4_cidr_block     = "172.16.0.0/28"
  master_authorized_networks = var.master_authorized_networks

  depends_on = [
    google_project_service.required,
    google_compute_router_nat.this,
  ]
}
