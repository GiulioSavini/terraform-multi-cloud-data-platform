output "lake_zones" {
  description = "Storage zones, keyed by zone rather than by bucket name."
  value       = module.data_platform.lake_zones
}

output "warehouses" {
  description = "Analytics query endpoints."
  value       = module.data_platform.warehouses
}

output "catalog" {
  description = "Cross-cloud data catalog."
  value       = module.data_platform.catalog
}

output "compliance_evidence" {
  description = "Control evidence for this deployment, read from the context contracts."
  value       = module.data_platform.compliance_evidence
  sensitive   = true
}
