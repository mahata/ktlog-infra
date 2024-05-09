terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }

  backend "s3" {
    bucket = "ktlog-tf-state"
    key    = "tofu.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  project = "ktlog"

  common_tags = {
    Environment = var.environment
    Name        = "${local.project}-${var.environment}"
    Project     = local.project
  }
}

module "networking" {
  source            = "./modules/networking"
  base_cidr_block   = var.base_cidr_block
  environment       = var.environment
  project           = local.project
  common_tags       = local.common_tags
  public_subnet_ids = module.subnet.public_subnet_ids
}

module "subnet" {
  source                = "./modules/subnet"
  common_tags           = local.common_tags
  public_route_table_id = module.networking.public_route_table_id
  vpc_id                = module.networking.vpc_id
  nat_gateway_id        = module.networking.nat_gateway_id
}

module "secret-manager" {
  source      = "./modules/secret-manager"
  environment = var.environment
  project     = local.project
}

module "domain" {
  source         = "./modules/domain"
  app_subdomain  = var.app_subdomain
  common_tags    = local.common_tags
  eb_lb_dns_name = module.app.beanstalk_alb_dns_name
  eb_lb_zone_id  = module.app.beanstalk_alb_zone_id
}

module "eice" {
  source            = "./modules/eice"
  base_cidr_block   = var.base_cidr_block
  environment       = var.environment
  project           = local.project
  common_tags       = local.common_tags
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.subnet.public_subnet_ids
}

module "app" {
  source             = "./modules/app"
  environment        = var.environment
  base_cidr_block    = var.base_cidr_block
  multi_az           = var.rds_multi_az
  project            = local.project
  common_tags        = local.common_tags
  vpc_id             = module.networking.vpc_id
  eice_ssh_id        = module.eice.eice_ssh_id
  public_subnet_ids  = module.subnet.public_subnet_ids
  private_subnet_ids = module.subnet.private_subnet_ids
  acm_cert_arn       = module.domain.acm_cert_arn
  rds_username       = module.secret-manager.rds_username
  rds_password       = module.secret-manager.rds_password
  rds_db_name        = module.secret-manager.rds_db_name
}

# module "rds" {
#   source                      = "./modules/rds"
#   environment                 = var.environment
#   multi_az                    = var.rds_multi_az
#   common_tags                 = local.common_tags
#   project                     = local.project
#   vpc_id                      = module.networking.vpc_id
#   private_subnet_ids          = module.subnet.private_subnet_ids
#   beanstalk_security_group_id = module.beanstalk.beanstalk_security_group_id
#   rds_username                = module.secret-manager.rds_username
#   rds_password                = module.secret-manager.rds_password
#   rds_db_name                 = module.secret-manager.rds_db_name
# }
