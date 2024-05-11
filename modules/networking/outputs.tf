output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_route_table_id" {
  value       = aws_route_table.internet_gateway.id
  description = "The ID of the Public Route Table"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.public_1.id
  description = "The ID of the Public Nat Gateway"
}
