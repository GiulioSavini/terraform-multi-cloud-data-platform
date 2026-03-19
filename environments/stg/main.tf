# -----------------------------------------------------------------------------
# Staging Environment - Multi-Cloud Data Platform
# Mid-range sizing for pre-production validation
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}
