output "ecr_repository_id" {
  description = "Get the ID of ECR Repository"
  value       = aws_ecr_repository.this.id
}