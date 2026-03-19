output "instance_name" { value = google_sql_database_instance.main.name }
output "connection_name" { value = google_sql_database_instance.main.connection_name }
output "private_ip" { value = google_sql_database_instance.main.private_ip_address }
output "database_name" { value = google_sql_database.main.name }
output "admin_password" { value = random_password.db_password.result; sensitive = true }
