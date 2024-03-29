terraform {
  cloud {
    organization = "liam-new-org"

    workspaces {
      tags = ["aws-infrastructure"]
    }
  }

  # Terraform version
  required_version = "~> 1.3"
}

locals {
  namespace = "${var.app_name}-${var.environment}"
}

module "network" {
  source = "../modules/network"

  base_cidr_block = "10.0.0.0/16"
  namespace       = local.namespace
}

module "s3" {
  source = "../modules/s3"

  namespace   = local.namespace
  bucket_name = "${var.app_name}-${var.s3_main_bucket_name}"
}

module "rds" {
  source = "../modules/db"

  username               = var.rds_username
  db_password            = var.rds_password
  namespace              = "${var.owner}${var.environment}"
  instance_class         = var.rds_instance_type
  subnet_ids             = module.network.private_subnet_ids
  vpc_security_group_ids = [module.network.rds_security_group_id]
}

module "elasticache" {
  source = "../modules/elasticache"

  namespace          = local.namespace
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [module.network.elasticache_security_group_id]

  node_type       = var.elasticache_node_type
  num_cache_nodes = var.elasticache_number_cache_nodes
}

module "ssm" {
  source = "../modules/ssm"

  parameters = {
    "/${local.namespace}/DATABASE_URL" : "postgresql://${var.rds_username}:${var.rds_password}@${module.rds.rds_endpoint}/${local.namespace}-db",
    "/${local.namespace}/REDIS_ENDPOINT_ADDRESS" : module.elasticache.primary_endpoint_address,
    "/${local.namespace}/SECRET_KEY_BASE" : var.secret_key_base
  }
}

module "ecs" {
  source = "../modules/ecs"

  region               = var.region
  namespace            = local.namespace
  app_port             = var.app_port
  ecr_repo_name        = var.ecr_repo_name
  ecr_tag              = var.ecr_tag
  desired_count        = var.ecs.task_desired_count
  cpu                  = var.ecs.task_cpu
  memory               = var.ecs.task_memory
  web_container_cpu    = var.ecs.web_container_cpu
  web_container_memory = var.ecs.web_container_memory

  alb_target_group_arn = module.network.alb_target_group_arn

  #TODO: Replace with private subnet groups when implemented
  subnets         = module.network.private_subnet_ids
  security_groups = [module.network.alb_security_group_id, module.network.ecs_security_group_id]

  s3_bucket_name = module.s3.bucket_name

  environment_variables   = var.environment_variables
  parameter_store_secrets = module.ssm.secrets
}
