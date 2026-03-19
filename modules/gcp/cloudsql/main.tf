# -----------------------------------------------------------------------------
# GCP CloudSQL PostgreSQL Module
# Instance, HA, backups, private IP, read replicas, maintenance, flags
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Random Password
# -----------------------------------------------------------------------------

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# -----------------------------------------------------------------------------
# CloudSQL Instance
# -----------------------------------------------------------------------------

resource "google_sql_database_instance" "main" {
  name                = "${local.name_prefix}-pg"
  region              = var.region
  database_version    = "POSTGRES_15"
  deletion_protection = var.environment == "prd"

  settings {
    tier              = var.tier
    disk_size         = var.disk_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    availability_type = var.ha_enabled ? "REGIONAL" : "ZONAL"
    edition           = "ENTERPRISE"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = var.environment == "prd"
      transaction_log_retention_days = var.environment == "prd" ? 7 : 3

      backup_retention_settings {
        retained_backups = var.backup_retention
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    database_flags {
      name  = "log_temp_files"
      value = "0"
    }

    user_labels = {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------

resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
}

# -----------------------------------------------------------------------------
# Admin User
# -----------------------------------------------------------------------------

resource "google_sql_user" "admin" {
  name     = "dbadmin"
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
}

# -----------------------------------------------------------------------------
# Read Replicas
# -----------------------------------------------------------------------------

resource "google_sql_database_instance" "replica" {
  count = var.read_replicas

  name                 = "${local.name_prefix}-pg-replica-${count.index + 1}"
  region               = var.region
  database_version     = "POSTGRES_15"
  master_instance_name = google_sql_database_instance.main.name
  deletion_protection  = var.environment == "prd"

  settings {
    tier            = var.tier
    disk_autoresize = true
    disk_type       = "PD_SSD"
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }

    user_labels = {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
      role        = "replica"
    }
  }

  replica_configuration {
    failover_target = false
  }
}
