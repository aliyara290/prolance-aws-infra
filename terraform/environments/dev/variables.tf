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

variable "ecs_services" {
  type = map(object({
    service_name = string

    container_definitions = map(object({
      container_name  = string
      container_image = string
      essential       = bool

      port_mappings = list(object({
        name           = string
        container_port = number
        host_port      = number
        protocol       = string
      }))

      environment_variables = map(string)

      secrets_arn = map(string)

      aws_log_group = string
    }))

    cpu    = number
    memory = number

    desired_count = number
  }))
}
