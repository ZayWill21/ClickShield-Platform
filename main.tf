# The configuration for the `remote` backend.
     terraform {
       backend "remote" {
         # The name of your Terraform Cloud organization.
         organization = "var.tfcloud_org"

         # The name of the Terraform Cloud workspace to store Terraform state files in.
         workspaces {
           name = "var.tfcloud_workspace"
         }
       }
     }
     
resource "null_resource" "example" {
       triggers = {
         value = "A example resource that does nothing!"
       }
     }
