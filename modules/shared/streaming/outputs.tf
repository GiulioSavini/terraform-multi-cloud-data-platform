output "msk_connect_role_arn" { value = aws_iam_role.msk_connect.arn }
output "connector_plugins_bucket" { value = aws_s3_bucket.connector_plugins.id }
