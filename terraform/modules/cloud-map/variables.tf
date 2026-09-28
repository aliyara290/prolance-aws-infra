variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "namespace_name" {
  description = "Private DNS namespace name"
  type        = string
}

variable "service_discovery_services" {
  description = "Cloud Map service discovery services to create within the private DNS namespace."

  type = map(object({
    ttl            = optional(number, 10)
    type           = optional(string, "A")
    routing_policy = optional(string, "MULTIVALUE")
  }))

  validation {
    condition = alltrue([
      for service in values(var.service_discovery_services) :
      contains(["WEIGHTED", "MULTIVALUE"], service.routing_policy)
    ])

    error_message = "Each routing_policy must be either WEIGHTED or MULTIVALUE."
  }

  validation {
    condition = alltrue([
      for service in values(var.service_discovery_services) :
      contains(["A", "AAAA", "SRV"], service.type)
    ])

    error_message = "Each type must be A, AAAA, or SRV."
  }

  validation {
    condition = alltrue([
      for service in values(var.service_discovery_services) :
      service.ttl > 0
    ])

    error_message = "Each service TTL must be greater than 0."
  }
}