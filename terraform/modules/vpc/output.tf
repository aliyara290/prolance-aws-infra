output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = [for subnet in aws_subnet.private_app_subnets : subnet.id]
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = [for subnet in aws_subnet.private_db_subnets : subnet.id]
}