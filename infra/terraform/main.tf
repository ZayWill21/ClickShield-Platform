
resource "aws_ebs_volume" "aws" {
  availability_zone = "us-east-1a"
  size              = 10
  tags = {
    "CreatedBy" = "Terraform"
  }
}

module "networking" {
  source = "./aws/networking"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  VPC_CIDR             = var.VPC_CIDR
  AWS_REGION           = var.AWS_REGION
  ZEROS                = var.ZEROS
}
