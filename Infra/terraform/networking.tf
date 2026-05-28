provider "aws" {
  region = var.AWS_REGION
}

# 1. Create VPC
resource "aws_vpc" "vpc_main" {
  cidr_block = var.VPC_CIDR
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "CreatedBy" = "Terraform"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    "CreatedBy" = "Terraform"
  }
}

# 3. Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnet_cidrs[count.index] 
  availability_zone = var.availability_zones[count.index]
    tags = {
    "CreatedBy" = "Terraform"
  }
}

# 4. Create Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
    tags = {
    "CreatedBy" = "Terraform"
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
  }
}

# 6. Associate Public Subnets to Public Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnets.id
  route_table_id = aws_route_table.public_rt.id
  
}

# 7. NAT Gateway Setup (Allocates static IP and deploys in public subnet)
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
    tags = {
    "CreatedBy" = "Terraform"
  }
}

# 8. Create NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id # Must be deployed in a public subnet
  depends_on = [ aws_internet_gateway.gw ]
    tags = {
    "CreatedBy" = "Terraform"
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
  }
}

# 10. Associate Private Subnets to Private Route Table
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

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