# ------------------------------------------------------------------------------
# Naming — shared kernel
#
# Single source of truth for resource names. Every bounded context derives its
# names here so that a resource can be traced back to its context and
# environment from the name alone, without reading tags.
#
# This module creates no resources. It exists so the naming rule lives in one
# place instead of being re-implemented as string interpolation in 17 modules.
# ------------------------------------------------------------------------------

locals {
  # Canonical prefix: <landing-zone>-<env>-<context>
  prefix = "${var.landing_zone}-${var.environment}-${var.context}"

  # Some providers reject dashes (Azure storage accounts, GCP buckets in some
  # APIs) or impose a 24-character ceiling. This is the compacted form.
  prefix_compact = substr(
    replace("${var.landing_zone}${var.environment}${var.context}", "-", ""),
    0, 20
  )
}
