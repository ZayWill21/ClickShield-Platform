# The configuration for the `remote` backend.
terraform {
  backend "s3" {

  }
}

resource "null_resource" "example" {
       triggers = {
         value = "A example resource that does nothing!"
       }
     }

