terraform {
  backend "s3" {
    bucket        = "s3"
    key           = "terraform.tfstate"
    region        = "eu-central-1"
    assume_role = {
      role_arn     = "xxx"
      session_name = "xxx"
    }
    encrypt       = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.35"
    }
  }
}
