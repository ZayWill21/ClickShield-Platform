# The configuration for the `remote` backend.
     terraform {
       backend "remote" {
         hostname = "app.terraform.io"
       }
     }

resource "null_resource" "example" {
       triggers = {
         value = "A example resource that does nothing!"
       }
     }
