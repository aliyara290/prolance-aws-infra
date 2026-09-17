provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Prolance"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Ali Yara"
    }
  }
}