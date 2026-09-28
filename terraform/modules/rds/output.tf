output "identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.identifier
}

output "endpoint" {
  description = "RDS endpoint including port"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "RDS hostname"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial database name"
  value       = aws_db_instance.this.db_name
}

output "arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}