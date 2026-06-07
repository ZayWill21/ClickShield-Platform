variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID where the EKS cluster will be deployed"
  type        = string
}

variable "VPC_CIDR" {
  type        = string
  description = "The main CIDR block for the VPC"
}

variable "ZEROS" {
  type = string
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availablity zone"
}

variable "encrypt" {
  type = string
  description = "Specifys Encryption"
}

variable "ecr_kms_arn" {
  type = string
  description = "The ARN of the KMS key to use for encrypting the ECR repository"
}

variable "eks_kms_arn" {
  type = string
  description = "The ARN of the KMS key to use for encrypting the EKS cluster"
}

variable "eks_cluster_role" {
  type = string
  description = "eks cluster IAM role"
}

variable "eks_node_group_role" {
  type = string
  description = "The ARN of the IAM role to use for the EKS node group"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

# variable "Access_Key_ID" {
#   type = string
#   description = "AWS Access Key ID for GitHub Actions"
# }