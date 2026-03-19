locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "google_compute_network" "main" {
  name                    = "${local.name_prefix}-vpc"
  project                 = var.gcp_project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "data" {
  name                     = "${local.name_prefix}-data"
  project                  = var.gcp_project_id
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "main" {
  name    = "${local.name_prefix}-router"
  project = var.gcp_project_id
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  name                               = "${local.name_prefix}-nat"
  project                            = var.gcp_project_id
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config { enable = true; filter = "ERRORS_ONLY" }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${local.name_prefix}-allow-internal"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = [var.subnet_cidr]
}

resource "google_compute_firewall" "deny_all" {
  name     = "${local.name_prefix}-deny-all"
  project  = var.gcp_project_id
  network  = google_compute_network.main.name
  priority = 65534

  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
}
