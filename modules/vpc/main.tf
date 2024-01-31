/**
 * # About
 *
 * Module for an AWS VPC
 * 
 */

resource "aws_vpc" "vpc_main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.tags
}

# Public Subnet
resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.vpc_main.id
  #   cidr_block              = "10.0.0.0/24
  #   map_public_ip_on_launch = true"
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = var.tags
}

resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.vpc_main.id
  #   cidr_block              = "10.0.1.0/24
  #   map_public_ip_on_launch = true"
  cidr_block              = var.private_subnet_cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = var.tags
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id
  tags   = var.tags
}

# NAT Gateway
resource "aws_eip" "eip_nat_gw" {
  tags = var.tags
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat_gw.id
  subnet_id     = aws_subnet.subnet_public.id
  tags          = var.tags
}

# Public Route Table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc_main.id
  tags   = var.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Private Route Table
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc_main.id
  tags   = var.tags

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.route_table_private.id
}
