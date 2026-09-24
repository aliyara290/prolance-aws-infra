output "ecr_repository_ids" {
  description = "IDs of the ECR repositories"

  value = {
    for name, repository in aws_ecr_repository.this :
    name => repository.id
  }
}