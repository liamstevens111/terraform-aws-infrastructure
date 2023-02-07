locals {
  secret_parameters = [
    for parameter in aws_ssm_parameter.main :
    tomap({ name = reverse(split("/", parameter.name))[0], arn = parameter.arn })
  ]
}

output "secrets" {
  value = local.secret_parameters
}
