variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}


variable "public_subnets" {
  description = "VPC Subnets"
  type = map(object({
    cidr_block = string
    az         = string
  }))
}

variable "private_application_subnets" {
  description = "VPC Subnets"
  type = map(object({
    cidr_block = string
    az         = string
  }))
}

variable "private_database_subnets" {
  description = "VPC Subnets"
  type = map(object({
    cidr_block = string
    az         = string
  }))
}