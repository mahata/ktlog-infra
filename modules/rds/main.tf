resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds"
  description = "RDS Access from Beanstalk"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "TCP"
    security_groups = [var.beanstalk_security_group_id]
  }

  tags = var.common_tags
}

resource "aws_db_subnet_group" "private" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = var.common_tags
}

resource "aws_db_instance" "ktlog" {
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "16.2"

  identifier             = "${var.project}-${var.environment}-db"
  instance_class         = "db.t4g.micro"
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  multi_az               = var.multi_az
  storage_encrypted      = true
  db_subnet_group_name   = aws_db_subnet_group.private.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = var.common_tags
}
