output "catalog" {
  description = "Full control catalog, keyed by control id."
  value       = local.controls
}

output "control_ids" {
  description = "Control ids claimed by this landing zone."
  value       = sort(keys(local.controls))
}

output "by_framework" {
  description = "Control ids grouped by framework, for building an audit response."
  value = {
    for fw in local.frameworks :
    fw => sort([for id, c in local.controls : id if c.frameworks[fw] != "—"])
  }
}

output "critical_control_ids" {
  description = "Controls whose failure blocks a release. CI treats a violation of these as fatal."
  value       = sort([for id, c in local.controls : id if c.severity == "critical"])
}
