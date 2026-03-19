locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "google_compute_global_address" "private_ip" {
  name          = "${local.name_prefix}-sql-ip"
  project       = var.gcp_project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

resource "google_service_networking_connection" "private" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}

resource "google_sql_database_instance" "main" {
  name             = "${local.name_prefix}-pg"
  project          = var.gcp_project_id
  region           = var.region
  database_version = "POSTGRES_15"

  settings {
    tier              = var.tier
    disk_size         = var.disk_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    availability_type = var.environment == "prd" ? "REGIONAL" : "ZONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = var.environment == "prd"
      backup_retention_settings {
        retained_backups = var.environment == "prd" ? 35 : 7
      }
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 3
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    user_labels = var.labels
  }

  deletion_protection = var.environment == "prd"

  depends_on = [google_service_networking_connection.private]
}

resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
  project  = var.gcp_project_id
}

resource "google_sql_user" "admin" {
  name     = "dbadmin"
  instance = google_sql_database_instance.main.name
  project  = var.gcp_project_id
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 24
  special = true
}

# Read Replica (production only)
resource "google_sql_database_instance" "replica" {
  count = var.environment == "prd" ? 1 : 0

  name                 = "${local.name_prefix}-pg-replica"
  project              = var.gcp_project_id
  region               = var.region
  database_version     = "POSTGRES_15"
  master_instance_name = google_sql_database_instance.main.name

  settings {
    tier            = var.tier
    disk_autoresize = true
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    user_labels = var.labels
  }

  replica_configuration {
    failover_target = false
  }
}
