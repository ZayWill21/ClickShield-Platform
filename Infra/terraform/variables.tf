variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "The main CIDR block for the VPC"
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

variable "tfcloud_org" {
  type = string
  description = "The name of your Terraform Cloud organization."
}

variable "tfcloud_workspace" {
  type = string
  description = "The name of your Terraform workspace"
}