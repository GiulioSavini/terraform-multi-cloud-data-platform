output "prefix" {
  description = "Canonical name prefix: <landing-zone>-<env>-<context>."
  value       = local.prefix
}

output "prefix_compact" {
  description = "Alphanumeric-only prefix, max 20 chars, for providers that reject dashes or cap length."
  value       = local.prefix_compact
}
