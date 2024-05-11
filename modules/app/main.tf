resource "aws_security_group" "beanstalk" {
  name        = "${var.project}-${var.environment}-beanstalk-env"
  description = "Security Group for Elastic Beanstalk"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.base_cidr_block]
  }

  ingress {
    description     = "Allow SSH from EICE"
    security_groups = [var.eice_ssh_id]
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
  }

  tags = var.common_tags
}

resource "aws_elastic_beanstalk_application" "ktlog" {
  name        = "${var.project}-${var.environment}"
  description = "${var.project}-${var.environment}"
}

resource "aws_elastic_beanstalk_environment" "ktlog" {
  name                = "${var.project}-${var.environment}"
  application         = aws_elastic_beanstalk_application.ktlog.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.2.3 running Corretto 21"
  tier                = "WebServer"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro" # TODO
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "eb-instance-profile"  # Created manually on AWS Console
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.beanstalk.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_PROFILES_ACTIVE"
    value     = var.environment
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private_subnet_ids)
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public_subnet_ids)
  }

  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = false
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = true
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.acm_cert_arn
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLPolicy"
    value     = "ELBSecurityPolicy-2016-08"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/"
  }

  # TODO: Check if this is deletable
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = 80
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SPRING_DATASOURCE_URL"
    # value     = "jdbc:postgresql://${var.rds_endpoint}:5432/${var.rds_db_name}"
    value     = "jdbc:postgresql://${aws_db_instance.ktlog.address}:5432/${var.rds_db_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_DATASOURCE_USERNAME"
    value     = var.rds_username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_DATASOURCE_PASSWORD"
    value     = var.rds_password
  }
}

data "aws_lb" "beanstalk_alb" {
  arn = aws_elastic_beanstalk_environment.ktlog.load_balancers[0]
}

resource "aws_lb_listener" "https_redirect" {
  load_balancer_arn = data.aws_lb.beanstalk_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group_rule" "allow_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = tolist(data.aws_lb.beanstalk_alb.security_groups)[0]
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds"
  description = "RDS Access from Beanstalk"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol = "TCP"
    # security_groups = [var.beanstalk_security_group_id]
    security_groups = [aws_security_group.beanstalk.id]
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
