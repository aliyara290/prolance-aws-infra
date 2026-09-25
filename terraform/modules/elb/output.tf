output "elb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

output "elb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "elb_zone_id" {
  description = "Canonical hosted zone ID of the ALB"
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "Map of target group ARNs keyed by target group key"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}

output "target_group_names" {
  description = "Map of target group names keyed by target group key"
  value       = { for k, v in aws_lb_target_group.this : k => v.name }
}

output "listener_arns" {
  description = "Map of listener ARNs keyed by listener key"
  value       = { for k, v in aws_lb_listener.this : k => v.arn }
}

output "listener_rule_arns" {
  description = "Map of listener rule ARNs keyed by rule key"
  value       = { for k, v in aws_lb_listener_rule.this : k => v.arn }
}