variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "s3_bucket_name" {
  type = string
}

variable "parameter_store_secrets" {
  type = set(object({
    name = string
    arn  = string
  }))
}

variable "app_port" {
  description = "Application running port"
  type        = number
}

variable "ecr_repo_name" {
  description = "ECR repo name"
  type        = string
}

variable "ecr_tag" {
  description = "ECR tag to deploy"
  type        = string
}

variable "cpu" {
  description = "ECS task definition CPU"
  type        = number
}

variable "memory" {
  description = "ECS task definition memory"
  type        = number
}

variable "desired_count" {
  description = "ECS task definition instance number"
  type        = number
}

variable "web_container_cpu" {
  description = "ECS web container CPU"
  type        = number
}

variable "web_container_memory" {
  description = "ECS web container memory"
  type        = number
}

variable "environment_variables" {
  description = "List of [{name = \"\", value = \"\"}] pairs of environment variables"
  type = set(object({
    name  = string
    value = string
  }))
}
