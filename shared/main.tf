terraform {
  cloud {
    organization = "liam-new-org"

    workspaces {
      name = "terraform-aws-infrastructure-shared"
    }
  }

  # Terraform version
  required_version = "~> 1.3"
}

module "ecr" {
  source = "../modules/ecr"

  namespace = var.namespace
}
