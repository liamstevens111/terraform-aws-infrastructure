variable "namespace" {
  type = string
}

variable "db_name" {
  type = string
}

variable "username" {
  description = "The DB master username"
  type        = string
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}
