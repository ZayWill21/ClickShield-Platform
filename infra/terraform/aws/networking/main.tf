# 1. Create VPC
resource "aws_vpc" "vpc_main" {
  cidr_block = var.VPC_CIDR
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
}

resource "aws_flow_log" "flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc_main.id
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = "flow-log-group"
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpc_flow_logs_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  description = "IAM role for VPC Flow Logs"
}
  


import {
  to = aws_iam_role.vpc_flow_logs_role
  id = var.vpc_flow_logs_role
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
}

# 3. Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each = zipmap(var.availability_zones, var.private_subnet_cidrs)

  vpc_id            = aws_vpc.vpc_main.id
  availability_zone = each.key    
  cidr_block        = each.value   

  tags = {
    Name        = "private-${each.key}"
    CreatedBy   = "Terraform"
    "auto-delete" = "no"
  }
}

# 4. Public Subnets
resource "aws_subnet" "public_subnets" {
  for_each = zipmap(var.availability_zones, var.public_subnet_cidrs)

  vpc_id            = aws_vpc.vpc_main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name      = "public-${each.key}"
    CreatedBy = "Terraform"
  }
}

# 5. Public Route Table & Association (Allows internet access)
resource "aws_route_table" "public_rt" {
  depends_on = [ aws_internet_gateway.gw ]
  vpc_id = aws_vpc.vpc_main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
    tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
}

# 6. Associate Public Subnets to Public Route Table
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. NAT Gateway Setup (Allocates static IP and deploys in public subnet)
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
    tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
}

# 8. Create NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0] .id # Must be deployed in a public subnet
  depends_on = [ aws_internet_gateway.gw ]
    tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
}

# 9. Private Route Table (Routes through NAT for internet access)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id # Points to NAT, not IGW
  }
    tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
}

# 10. Associate Private Subnets to Private Route Table
resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
