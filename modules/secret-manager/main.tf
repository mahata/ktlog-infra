locals {
  path = "${var.environment}/${var.project}"
}

data "aws_secretsmanager_secret" "rds" {
  name = "${local.path}/rds"
}

data "aws_secretsmanager_secret_version" "rds_version" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}
