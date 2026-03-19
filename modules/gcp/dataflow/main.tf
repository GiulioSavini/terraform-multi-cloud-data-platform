locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "google_service_account" "dataflow" {
  account_id   = "${local.name_prefix}-dataflow"
  display_name = "Dataflow SA - ${var.environment}"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "dataflow_worker" {
  project = var.gcp_project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_project_iam_member" "dataflow_bq" {
  project = var.gcp_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_project_iam_member" "dataflow_storage" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_storage_bucket" "temp" {
  name          = "${local.name_prefix}-dataflow-temp-${var.gcp_project_id}"
  project       = var.gcp_project_id
  location      = var.region
  force_destroy = var.environment != "prd"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition { age = 7 }
    action { type = "Delete" }
  }

  labels = var.labels
}

resource "google_storage_bucket" "staging" {
  name          = "${local.name_prefix}-dataflow-staging-${var.gcp_project_id}"
  project       = var.gcp_project_id
  location      = var.region
  force_destroy = var.environment != "prd"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition { age = 30 }
    action { type = "Delete" }
  }

  labels = var.labels
}
