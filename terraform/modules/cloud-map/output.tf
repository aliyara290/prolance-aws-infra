output "namespace_id" {
  description = "Cloud Map namespace ID"
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "namespace_arn" {
  description = "Cloud Map namespace ARN"
  value       = aws_service_discovery_private_dns_namespace.this.arn
}

output "namespace_name" {
  description = "Cloud Map namespace name"
  value       = aws_service_discovery_private_dns_namespace.this.name
}

output "discovery_service_ids" {
  value = {
    for name, service in aws_service_discovery_service.service :
    name => service.id
  }
}

output "discovery_service_arns" {
  description = "ARNs of the created discovery services"
  value = {
    for name, service in aws_service_discovery_service.service :
    name => service.arn
  }
}