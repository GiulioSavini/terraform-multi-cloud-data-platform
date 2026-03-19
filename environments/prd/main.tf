# -----------------------------------------------------------------------------
# Production Environment - Multi-Cloud Data Platform
# Full HA sizing with multi-AZ, geo-replication, extended backups
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}
