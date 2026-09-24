module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr

  public_subnets = var.public_subnets

  private_application_subnets = var.private_application_subnets

  private_database_subnets = var.private_database_subnets
}


module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment

  repositories = [
    "api-gateway",
    "tenant-service",
    "project-service",
    "tasks-service",
    "eureka-server",
    "config-server",
    "attachment-service",
    "billing-service",
    "crm-service",
    "notification-service"
  ]

  image_tag_mutability = "IMMUTABLE"

  scan_on_push = true

  encryption_type = "AES256"

  keep_image_count = 15
}


module "ecs" {
  source = "../../modules/ecs-service"

  
}