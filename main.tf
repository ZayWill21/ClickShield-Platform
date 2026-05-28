# The configuration for the `remote` backend.
terraform {
  backend "s3" {
    bucket = "terraform-backendqwer1234-298350610133-us-east-1-an"
    key    = "path/terraform.tfstate"
    region = "us-east-1"
  }
}