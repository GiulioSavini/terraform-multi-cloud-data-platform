# -----------------------------------------------------------------------------
# Dev Environment - Multi-Cloud Data Platform
# Minimal sizing for development and testing
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}
