resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name = each.value

  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key
  }

  tags = {
    Name = "Prolance-${var.environment}-${each.value}-repo"

  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  # ecr lifecycle policy to delete old images version auto, and keep just the last 20 image
  policy = jsonencode({
    rules = [
      {
        rulePeriority = 1
        description   = "Expire images older than 20d"
        selection = {
          tagStatus   = "tagged"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

}