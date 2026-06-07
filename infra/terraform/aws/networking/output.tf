# Export VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = values(aws_subnet.private_subnets)[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = values(aws_subnet.public_subnets)[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = values(aws_subnet.private_subnets)[*].cidr_block
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = values(aws_subnet.public_subnets)[*].cidr_block
}

output "flow_logs" {
  value = aws_flow_log.flow_logs.arn
}

output "flow_log_role" {
  value = aws_iam_role.flow_logs_role.arn
}