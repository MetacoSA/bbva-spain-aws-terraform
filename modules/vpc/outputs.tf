output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.subnet_public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.subnet_private.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gw.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.route_table_public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.route_table_private.id
}
