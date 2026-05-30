# This file defines the main Terraform configuration for the ClickShield Platform infrastructure. It includes the necessary modules to set up the AWS networking components.
module "networking" {
  source = "./aws/networking"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  VPC_CIDR             = var.VPC_CIDR
  AWS_REGION           = var.AWS_REGION
  ZEROS                = var.ZEROS
}

