module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr

  public_subnets = var.public_subnets

  private_application_subnets = var.private_application_subnets

  private_database_subnets = var.private_database_subnets
}
