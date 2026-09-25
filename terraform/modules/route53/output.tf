output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Route 53 hosted zone name"
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "Name servers for the hosted zone (only relevant for public zones)"
  value       = aws_route53_zone.this.name_servers
}

output "alias_record_fqdns" {
  description = "Map of alias record FQDNs keyed by record key"
  value       = { for k, v in aws_route53_record.alias : k => v.fqdn }
}

output "simple_record_fqdns" {
  description = "Map of simple record FQDNs keyed by record key"
  value       = { for k, v in aws_route53_record.simple : k => v.fqdn }
}