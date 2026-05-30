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

terraform {
  backend "s3" {
    bucket = "terraform-backendqwer1234-298350610133-us-east-1-an"
    key    = "path/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ebs_volume" "aws" {
  availability_zone = "us-east-1a"
  size              = 10
  tags = {
    "CreatedBy" = "Terraform"
  }
}

module "networking" {
  source = "./infra/terraform/aws/networking"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  VPC_CIDR             = var.VPC_CIDR
  AWS_REGION           = var.AWS_REGION
  ZEROS                = var.ZEROS
}

module "container_services" {
  source = "./infra/terraform/aws/container_services"
}