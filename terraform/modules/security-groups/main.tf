resource "aws_security_group" "this" {
  description = var.sg_description
  vpc_id      = var.vpc_id
  name        = var.sg_name

  tags = merge(
    {
      Name = var.sg_name
    },
    var.tags
  )
}


resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress_rules
  security_group_id = aws_security_group.this.id


  from_port = each.value.from_port
  to_port = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4 = each.value.cidr_ipv4
  description = each.value.description
  referenced_security_group_id = each.value.referenced_security_group_id
}


resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress_rules
  security_group_id = aws_security_group.this.id


  from_port = each.value.from_port
  to_port = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4 = each.value.cidr_ipv4
  description = each.value.description
  referenced_security_group_id = each.value.referenced_security_group_id
}
