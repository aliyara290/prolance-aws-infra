resource "aws_service_discovery_private_dns_namespace" "this" {
  name = var.namespace_name

  description = "Private DNS namespace for Prolance ECS services"

  vpc = var.vpc_id
}

resource "aws_service_discovery_service" "service" {
  for_each = var.service_discovery_services
  name     = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = each.value.ttl
      type = each.value.type
    }

    routing_policy = each.value.routing_policy
  }

}