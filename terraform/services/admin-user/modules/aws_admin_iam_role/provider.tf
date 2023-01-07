terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.41.0"
    }
  }
}
