terraform {
  backend "s3" {
    bucket = "terraform-backendqwer1234-298350610133-us-east-1-an"
    key    = "path/terraform.tfstate"
    region = "us-east-1"
  }
}

# The configuration for the `remote` backend.
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.92"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = var.AWS_REGION
}