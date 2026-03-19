locals {
  name_prefix = "${var.project}-${var.environment}"
  zones       = ["raw", "curated", "analytics"]
}

resource "google_storage_bucket" "zones" {
  for_each = toset(local.zones)

  name          = "${local.name_prefix}-${each.value}-${var.gcp_project_id}"
  project       = var.gcp_project_id
  location      = var.location
  force_destroy = var.environment != "prd"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = var.environment == "prd"
  }

  lifecycle_rule {
    condition { age = 30 }
    action { type = "SetStorageClass"; storage_class = "NEARLINE" }
  }

  lifecycle_rule {
    condition { age = 90 }
    action { type = "SetStorageClass"; storage_class = "COLDLINE" }
  }

  lifecycle_rule {
    condition { age = 365 }
    action { type = "Delete" }
  }

  labels = merge(var.labels, { zone = each.value })
}
