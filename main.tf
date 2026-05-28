# The configuration for the `remote` backend.
terraform {
  backend "s3" {
    bucket = var.S3_BUCKETNAME
    key    = var.S3_KEY_PATH
    region = var.AWS_REGION
  }
}

resource "null_resource" "example" {
       triggers = {
         value = "A example resource that does nothing!"
       }
     }

