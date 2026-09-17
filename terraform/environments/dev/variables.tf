variable "aws_region" {
  type        = string
  description = "AWS region where the Terraform state bucket will be created"
  default     = "eu-west-3"
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = var.environment == "development"
    error_message = "Environment must be development"
  }
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
}

variable "private_application_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
}

variable "private_database_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
}