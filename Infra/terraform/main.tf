# The configuration for the `remote` backend.
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