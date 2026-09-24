variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "service_name" {
  description = "ECS Service name"
  type        = string
}

variable "cluster_arn" {
  description = "ECS Cluster ARN"
  type        = string
}

variable "container_definitions" {
  description = "Container definition for ECS task"
  type = map(object({
    container_name = string
    container_image = string
    essential = bool

    port_mappings = list(object({
      name = string
      container_port = number
      host_port = number
      protocol = string
    }))

    environment_variables = map(string)

    secrets_arn = map(string) 

    aws_log_group = string
  }))

  validation {
    condition = length(var.container_definitions) <= 9
    error_message = "The maximum number of containers per task is 9."
  }
}

variable "cpu" {
  description = "Task CPU units"
  type        = number
}

variable "memory" {
  description = "Task memory in MiB"
  type        = number
}

variable "desired_count" {
  description = "Number of desired ECS tasks"
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count must be at least 1."
  }
}

variable "subnet_ids" {
  description = "Private subnets IDs where ECS tasks will run"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Private subnets must be at least 2 to achieve high availabity"
  }
}

variable "security_groups_ids" {
  description = "Security Groups that will be attached to the ECS Tasks"
  type        = list(string)
  validation {
    condition     = length(var.security_groups_ids) >= 1
    error_message = "At least one security group must be provided"
  }
}

variable "assign_public_ip" {
  description = "Whether the ECS task receive public IP addresses"
  type        = bool
  default     = false
}

# variable "execute_command" {
#   description = "Whether the Execution command should be enabled or not"
#   type        = bool
#   default     = true
# }

variable "platform_version" {
  description = "Fargate platform version"
  type        = string
  default     = "LATEST"
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period for the ECS Service"
  type        = number
  default     = 90
}

variable "deployment_minimum_health_percent" {
  description = "Minimum healthy percentage during deployment"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of the task during deployment"
  type        = number
  default     = 200
}

variable "deployment_circuit_breaker_enabled" {
  description = "Enable ECS deployment circuit breaker"
  type        = bool
  default     = true
}

variable "deployment_circuit_breaker_rollback" {
  description = "Rolleback failed ECS deployment"
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "ELB Target group if of course the service is behind an ELB"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables that will be passed to the ECS Tasks"
  type        = map(string)
  default     = {}
}


variable "additional_task_policy_statements" {
  description = "Additional IAM policy statements for ECS Task role"
  type        = list(object)
  default = []
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {}
}
