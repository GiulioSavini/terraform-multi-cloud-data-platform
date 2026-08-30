output "vpc_id" {
  description = "VPC network ID"
  value       = google_compute_network.main.id
}

output "vpc_name" {
  description = "VPC network name"
  value       = google_compute_network.main.name
}

output "vpc_self_link" {
  description = "VPC network self link"
  value       = google_compute_network.main.self_link
}

output "subnet_id" {
  description = "Primary data subnet ID"
  value       = google_compute_subnetwork.data.id
}

output "subnet_self_link" {
  description = "Primary data subnet self link"
  value       = google_compute_subnetwork.data.self_link
}

output "dataflow_subnet_self_link" {
  description = "Dataflow subnet self link"
  value       = google_compute_subnetwork.dataflow.self_link
}

output "private_ip_range_name" {
  description = "Private IP range name for service networking"
  value       = google_compute_global_address.private_ip_range.name
}

output "router_name" {
  description = "Cloud Router name"
  value       = google_compute_router.main.name
}
