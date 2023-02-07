variable "app_name" {
  description = "Application name"
}

variable "environment" {
  description = "The application environment, used to tag the resources, e.g. `acme-web-staging`"
  type        = string
}

variable "image_limit" {
  default     = 5
  description = "Sets max amount of the latest main images to be kept"
}

variable "owner" {
  description = "The owner of the infrastructure, used to tag the resources, e.g. `acme-web`"
  type        = string
}

variable "namespace" {
  description = "The namespace for the application infrastructure on AWS, e.g. acme-web"
  type        = string
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
  description = "AWS Secret Access Key"
  type        = string
}
