# Outputs for references 
output "vpc" {
  value = aws_vpc.vpc_main.id
}

output "subnet_private" {
  value = aws_subnet.private_subnets[*].arn
}

output "subnet_public" {
  value = aws_subnet.public_subnets[*].arn
}

output "nat_gateway" {
  value = aws_nat_gateway.nat.arn
}