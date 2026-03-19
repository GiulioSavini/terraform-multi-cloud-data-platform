# -----------------------------------------------------------------------------
# GCP Dataflow Module
# Service account, temp/staging buckets, job template configuration
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Service Account
# -----------------------------------------------------------------------------

resource "google_service_account" "dataflow" {
  account_id   = "${local.name_prefix}-dataflow"
  display_name = "Dataflow Service Account - ${var.environment}"
  description  = "Service account for Dataflow jobs in ${var.environment}"
}

resource "google_project_iam_member" "dataflow_worker" {
  project = google_service_account.dataflow.project
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_project_iam_member" "dataflow_bq" {
  project = google_service_account.dataflow.project
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_project_iam_member" "dataflow_storage" {
  project = google_service_account.dataflow.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_project_iam_member" "dataflow_pubsub" {
  project = google_service_account.dataflow.project
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

# -----------------------------------------------------------------------------
# Temp Bucket
# -----------------------------------------------------------------------------

resource "google_storage_bucket" "temp" {
  name          = "${local.name_prefix}-dataflow-temp-${random_id.suffix.hex}"
  location      = var.region
  force_destroy = var.environment != "prd"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }

  labels = var.labels
}

# -----------------------------------------------------------------------------
# Staging Bucket
# -----------------------------------------------------------------------------

resource "google_storage_bucket" "staging" {
  name          = "${local.name_prefix}-dataflow-staging-${random_id.suffix.hex}"
  location      = var.region
  force_destroy = var.environment != "prd"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = true
  }

  labels = var.labels
}

resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# Dataflow Flex Template (metadata resource)
# This provides the configuration; actual job execution is done via gcloud/API
# -----------------------------------------------------------------------------

resource "google_storage_bucket_object" "job_metadata" {
  name    = "templates/dataflow-job-metadata.json"
  bucket  = google_storage_bucket.staging.name
  content = jsonencode({
    name        = "${local.name_prefix}-etl-pipeline"
    description = "ETL pipeline from GCS to BigQuery"
    parameters = {
      inputPath     = "gs://${local.name_prefix}-raw-*/"
      outputTable   = "${local.name_prefix}_analytics.aggregated_metrics"
      tempLocation  = "gs://${google_storage_bucket.temp.name}/temp/"
      maxWorkers    = var.max_workers
      machineType   = var.machine_type
      network       = var.network
      subnetwork    = var.subnetwork
      serviceAccount = google_service_account.dataflow.email
      usePublicIps  = false
    }
  })
}
