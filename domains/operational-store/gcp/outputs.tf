output "instance_name" {
  description = "CloudSQL instance name"
  value       = google_sql_database_instance.main.name
}

output "connection_name" {
  description = "CloudSQL instance connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "private_ip" {
  description = "CloudSQL instance private IP address"
  value       = google_sql_database_instance.main.private_ip_address
}

output "database_name" {
  description = "Default database name"
  value       = google_sql_database.main.name
}

output "admin_password" {
  description = "Admin user password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "replica_connection_names" {
  description = "Read replica connection names"
  value       = google_sql_database_instance.replica[*].connection_name
}

output "replica_private_ips" {
  description = "Read replica private IPs"
  value       = google_sql_database_instance.replica[*].private_ip_address
}
