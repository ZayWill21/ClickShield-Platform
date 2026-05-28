# The configuration for the `remote` backend.
terraform {
  backend "s3" {
    bucket = secret("S3_BUCKETNAME")
    key    = secret("S3_KEY_PATH")
    region = secret("AWS_REGION")
  }
}

resource "null_resource" "example" {
       triggers = {
         value = "A example resource that does nothing!"
       }
     }

