variable "name" {
  description = "Name prefix for the Application Load Balancer"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and target groups are created"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "The ALB must be deployed across at least two subnets."
  }
}

variable "security_group_ids" {
  description = "Security groups attached to the ALB"
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) >= 1
    error_message = "At least one security group must be provided."
  }
}

variable "target_groups" {
  description = "Map of target groups to create. Keys are used in resource naming and as references for listener forwarding."
  type = map(object({
    port                  = number
    protocol              = optional(string, "HTTP")
    target_type           = optional(string, "ip")
    health_check_path     = optional(string, "/")
    healthy_threshold     = optional(number, 2)
    unhealthy_threshold   = optional(number, 3)
    health_check_timeout  = optional(number, 5)
    health_check_interval = optional(number, 30)
    health_check_matcher  = optional(string, "200-399")
  }))

  default = {}
}

variable "listeners" {
  description = "Map of ALB listeners to create. Use action_type 'forward' with a target_group_key, or 'redirect' with redirect settings."
  type = map(object({
    port            = number
    protocol        = string
    certificate_arn = optional(string)
    ssl_policy      = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")

    action_type      = string
    target_group_key = optional(string)

    redirect_port        = optional(string)
    redirect_protocol    = optional(string)
    redirect_status_code = optional(string)
  }))

  default = {}
}

variable "listener_rules" {
  description = "Map of listener rules. Each rule routes traffic based on conditions (path, host, method, source IP) to a target group, redirect, or fixed response."
  type = map(object({
    listener_key = string
    priority     = number

    action_type      = optional(string, "forward")
    target_group_key = optional(string)

    # Redirect action fields
    redirect_port        = optional(string)
    redirect_protocol    = optional(string)
    redirect_status_code = optional(string)

    # Fixed response action fields
    fixed_response_content_type = optional(string)
    fixed_response_message_body = optional(string)
    fixed_response_status_code  = optional(string)

    # Condition matchers (set one or more)
    path_patterns        = optional(list(string))
    host_headers         = optional(list(string))
    http_request_methods = optional(list(string))
    source_ips           = optional(list(string))
  }))

  default = {}
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}