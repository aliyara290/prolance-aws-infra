output "vpc_id" {
  description = "VPC ID"
  type        = string
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = module.vpc.private_db_subnet_ids
}

output "elb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.elb.alb_dns_name
}

output "elb_zone_id" {
  description = "Canonical hosted zone ID of the ALB."
  value       = module.elb.alb_zone_id
}

output "api_gateway_target_group_arn" {
  description = "ARN of the API Gateway target group."
  value       = module.alb.target_group_arns["api-gw"]
}