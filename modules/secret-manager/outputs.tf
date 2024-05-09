output "rds_username" {
  value = jsondecode(data.aws_secretsmanager_secret_version.rds_version.secret_string)["USERNAME"]
}

output "rds_password" {
  value = jsondecode(data.aws_secretsmanager_secret_version.rds_version.secret_string)["PASSWORD"]
}

output "rds_db_name" {
  value = jsondecode(data.aws_secretsmanager_secret_version.rds_version.secret_string)["DB_NAME"]
}
