# -----------------------------------------------------------------------------
# GCP Data Lake Module
# GCS buckets (raw/curated/analytics), lifecycle, CMEK, versioning
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  zones       = ["raw", "curated", "analytics"]
}

# -----------------------------------------------------------------------------
# CMEK Key Ring and Key
# -----------------------------------------------------------------------------

resource "google_kms_key_ring" "data_lake" {
  name     = "${local.name_prefix}-data-lake-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "data_lake" {
  name     = "${local.name_prefix}-data-lake-key"
  key_ring = google_kms_key_ring.data_lake.id

  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# GCS Buckets
# -----------------------------------------------------------------------------

resource "google_storage_bucket" "zones" {
  for_each = toset(local.zones)

  name          = "${local.name_prefix}-${each.value}-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = var.environment != "prd"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.data_lake.id
  }

  lifecycle_rule {
    condition {
      age = var.nearline_age_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.coldline_age_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 30
    }
    action {
      type = "Delete"
    }
  }

  logging {
    log_bucket        = google_storage_bucket.access_logs.name
    log_object_prefix = each.value
  }

  labels = merge(var.labels, {
    zone = each.value
  })
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# Access Logs Bucket
# -----------------------------------------------------------------------------

resource "google_storage_bucket" "access_logs" {
  name          = "${local.name_prefix}-access-logs-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = var.environment != "prd"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  labels = var.labels
}
