terraform {
  backend "s3" {

  }
}

# The configuration for the `remote` backend.
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = var.AWS_REGION
}