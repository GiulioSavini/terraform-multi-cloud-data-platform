output "lake_zones" {
  description = "Storage zones, keyed by zone rather than by bucket name."
  value       = module.data_lake.zones
}

output "operational_endpoints" {
  description = "Transactional store endpoints."
  value       = module.operational_store.endpoints
}

output "warehouses" {
  description = "Analytics query endpoints."
  value       = module.analytics_warehouse.warehouses
}

output "pipeline_identities" {
  description = "The only identities with write access to the raw and curated zones."
  value       = module.data_pipeline.pipeline_identities
}

output "catalog" {
  description = "Cross-cloud data catalog, when governance is enabled."
  value       = local.governance_enabled ? module.data_governance[0].catalog : null
}

output "compliance_evidence" {
  description = <<-EOT
    Control evidence read from the context contracts, ready to attach to an
    audit response. Every value comes from a contract output rather than being
    asserted by hand, so it cannot claim a control the code does not implement.
  EOT
  value = {
    "NET-01"   = module.networking.networks
    "LAKE-01"  = module.data_lake.encryption_keys
    "LAKE-02"  = module.data_lake.zones
    "STORE-01" = module.operational_store.credential_references
    "WH-01"    = module.analytics_warehouse.workload_identities
    "STR-01"   = module.stream_ingestion.cross_cloud_replication_enabled
    "STR-02"   = module.stream_ingestion.encryption_keys
    "PIPE-01"  = module.data_pipeline.pipeline_identities
    "GOV-01"   = local.governance_enabled ? module.data_governance[0].catalog : null
    "GOV-02"   = local.governance_enabled ? module.data_governance[0].governance_identities : null
  }
  sensitive = true
}

output "control_catalog" {
  description = "Controls this platform claims, grouped by framework."
  value       = module.controls.by_framework
}
