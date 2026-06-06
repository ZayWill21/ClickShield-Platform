# This file defines the main Terraform configuration for the ClickShield Platform infrastructure. It includes the necessary modules to set up the AWS networking components.
module "networking" {
  source = "./aws/networking"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  VPC_CIDR             = var.VPC_CIDR
  AWS_REGION           = var.AWS_REGION
  vpc_flow_logs_role   = var.vpc_flow_logs_role
  ZEROS                = var.ZEROS
}

module "container_services" {
  source = "./aws/container_services"
  
  # Networking outputs
  private_subnet_ids   = module.networking.private_subnet_ids[*]

  # Networking outputs variables
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
  VPC_CIDR             = var.VPC_CIDR
  ZEROS                = var.ZEROS
  
  # IAM and KMS outputs
  eks_cluster_role     = var.eks_cluster_role
  eks_node_group_role  = var.eks_node_group_role
  eks_kms_arn          = var.eks_kms_arn
  ecr_kms_arn          = var.ecr_kms_arn
  aws_account_id = var.aws_account_id
  
  # Other variables
  AWS_REGION           = var.AWS_REGION
  encrypt              = var.encrypt
  
  depends_on = [ module.networking ]
}

