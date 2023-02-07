variable "base_cidr_block" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Name to be used for the current environment, ie example-web-staging or example-web-production"
}
