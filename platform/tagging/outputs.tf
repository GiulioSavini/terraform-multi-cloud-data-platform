output "tags" {
  description = "Mandatory tag set for AWS and Azure resources."
  value       = local.tags
}

output "labels" {
  description = "Same tag set normalised to GCP label constraints."
  value       = local.labels
}

output "mandatory_keys" {
  description = "Keys that policy requires on every resource. Consumed by compliance/policies."
  value       = sort(keys(local.mandatory))
}
