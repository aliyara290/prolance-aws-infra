variable "aws_region" {
  type = string
  description = "AWS region where the Terraform state bucket will be created"
  default = "eu-west-3"
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = var.environment == "development"
    error_message = "Environment must be development"
  }
}