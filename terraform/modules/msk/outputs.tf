output "bootstrap_brokers" {
  description = "PLAINTEXT connection host:port pairs"
  value       = aws_msk_cluster.this.bootstrap_brokers
}

output "arn" {
  description = "ARN of the MSK cluster"
  value       = aws_msk_cluster.this.arn
}
