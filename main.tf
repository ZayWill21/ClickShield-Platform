# The configuration for the `remote` backend.
     terraform {
       backend "remote" {
         hostname = "app.terraform.io"
         workspaces {
           name = "ClickShield-Plateform"
         }
       }
     }
resource "null_resource" "example" {
       triggers = {
         value = "A example resource that does nothing!"
       }
     }

variable "tfcloud_workspace" {
       type = string
       description = "The name of the my tf cloud workspace "
     }
