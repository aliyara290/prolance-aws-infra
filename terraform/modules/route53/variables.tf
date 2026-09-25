variable "zone_name" {
  description = "The name of the hosted zone (e.g. prolance.local or prolance.com)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with the hosted zone. Set to create a private hosted zone, leave null for a public zone."
  type        = string
  default     = null
}

variable "alias_records" {
  description = "Map of alias DNS records to create. Keys are used as resource identifiers."
  type = map(object({
    name                   = string
    type                   = optional(string, "A")
    alias_dns_name         = string
    alias_zone_id          = string
    evaluate_target_health = optional(bool, true)
  }))

  default = {}
}

variable "simple_records" {
  description = "Map of simple DNS records (A, CNAME, TXT, etc.) to create. Keys are used as resource identifiers."
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))

  default = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}