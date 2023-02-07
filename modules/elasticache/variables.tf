variable "namespace" {
  type = string
}

variable "engine" {
  type    = string
  default = "redis"
}

variable "engine_version" {
  type    = string
  default = "6.x"
}

variable "port" {
  type    = number
  default = 6379
}

variable "node_type" {
  type = string
}

variable "num_cache_nodes" {
  type = number
}

variable "parameter_group_name" {
  type    = string
  default = "default.redis6.x"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
