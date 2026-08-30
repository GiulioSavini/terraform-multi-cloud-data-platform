# ------------------------------------------------------------------------------
# Tagging — shared kernel
#
# Emits the mandatory tag set. Compliance evidence is gathered by querying
# tags, so a resource missing these is effectively invisible to an audit even
# if it is correctly configured. Policy in compliance/policies rejects any
# plan that omits them.
#
# Two shapes are emitted because GCP labels are far more restrictive than AWS
# and Azure tags: lowercase, no spaces, limited punctuation.
# ------------------------------------------------------------------------------

locals {
  mandatory = {
    LandingZone        = var.landing_zone
    Environment        = var.environment
    BoundedContext     = var.context
    Owner              = var.owner
    CostCenter         = var.cost_center
    DataClassification = var.data_classification
    ComplianceScope    = join("-", sort(var.compliance_scope))
    ManagedBy          = "terraform"
  }

  tags = merge(var.extra, local.mandatory)

  # GCP labels: keys and values must match [a-z0-9_-], max 63 chars, and keys
  # must start with a lowercase letter.
  labels = {
    for k, v in local.tags :
    lower(replace(k, "/[^a-zA-Z0-9_-]/", "_")) => substr(lower(replace(v, "/[^a-zA-Z0-9_-]/", "_")), 0, 63)
  }
}
