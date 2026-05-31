variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
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

variable "vpc_flow_logs_role" {
  type = string
  description = "IAM role ARN for VPC Flow Logs"
}