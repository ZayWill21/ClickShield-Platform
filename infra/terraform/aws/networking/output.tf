# Export VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_main.id
}

# Export private subnet IDs
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

# Export public subnet IDs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

# Export private subnet CIDRs
output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private_subnets[*].cidr_block
}

# Export public subnet CIDRs
output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public_subnets[*].cidr_block
}