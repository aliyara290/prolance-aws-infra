variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "network_acl_rule_name" {
  description = "Network ACL Name"
  type        = string
}

variable "network_acl_rule" {
  description = "Network ACL rule"
  type = map(object({
    rule_number     = number
    egress          = bool
    protocol        = string
    rule_action     = string
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
    from_port       = number
    to_port         = number
  }))

  default = {}

  validation {
    condition = alltrue([
      for rule in var.network_acl_rule :
      contains(["allow", "deny"], rule.rule_action)
    ])
    error_message = "Rule action must be either allow or deny"
  }
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {}
}