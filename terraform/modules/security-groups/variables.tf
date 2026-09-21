variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "sg_name" {
  description = "Security Group Name"
  type        = string
}

variable "sg_description" {
  description = "Security Group Description"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "Inbound Rules for SG"
  type = map(object({
    description                  = string
    from_port                    = number
    to_port                      = number
    ip_protocol                  = string
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))

  default = {}
}

variable "egress_rules" {
  description = "Outbound Rules for SG"
  type = map(object({
    description                  = string
    from_port                    = number
    to_port                      = number
    ip_protocol                  = string
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))

  default = {}
}

variable "tags" {
  description = "Security Groupd Tags"
  type        = map(string)
  default     = {}
}