variable "app_name" {
  type = string
}

variable "environment" {
  description = "The application environment, used to tag the resources, e.g. `staging`"
  type        = string
}

variable "owner" {
  description = "The owner of the infrastructure, used to tag the resources, e.g. `acme-web`"
  type        = string
}

variable "app_port" {
  description = "Application running port"
  type        = number
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Access Key Secret"
  type        = string
}

variable "rds_instance_type" {
  description = "The RDB instance type"
  type        = string
}

variable "rds_username" {
  description = "RDS username"
  type        = string
}

variable "rds_password" {
  description = "RDS password"
  type        = string
}

variable "ecr_repo_name" {
  description = "ECR repo name"
  type        = string
}

variable "ecr_tag" {
  description = "ECR tag to deploy"
  type        = string
}

variable "ecs" {
  description = "ECS input variables"
  type = object({
    task_cpu             = number # See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html for the available values
    task_memory          = number
    task_desired_count   = number
    web_container_cpu    = number
    web_container_memory = number
  })
}

variable "elasticache_node_type" {
  description = "ElastiCache Node type"
  default     = "cache.t3.small"
}

variable "elasticache_number_cache_nodes" {
  description = "Number of cache nodes"
  default     = 1
}

variable "s3_main_bucket_name" {
  description = "The name of the S3 main bucket without the namespace prefix"
  type        = string
}

variable "secret_key_base" {
  description = "The Secret key base for the application"
  type        = string
}

variable "environment_variables" {
  description = "List of [{name = \"\", value = \"\"}] pairs of environment variables"
  type = set(object({
    name  = string
    value = string
  }))
}
