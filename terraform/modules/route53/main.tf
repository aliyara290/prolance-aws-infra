resource "aws_route53_zone" "this" {
  name = var.zone_name

  dynamic "vpc" {
    for_each = var.vpc_id != null ? [1] : []

    content {
      vpc_id = var.vpc_id
    }
  }

  tags = merge(
    {
      Name = var.zone_name
    },
    var.tags
  )
}


resource "aws_route53_record" "alias" {
  for_each = var.alias_records

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = each.value.alias_dns_name
    zone_id                = each.value.alias_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}


resource "aws_route53_record" "simple" {
  for_each = var.simple_records

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}