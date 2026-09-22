resource "aws_network_acl" "this" {
  vpc_id = var.vpc_id

  tags = merge({
    Name = "Prolance-${var.environment}-${var.network_acl_rule_name}-nacl"
    },
    var.tags
  )
}

resource "aws_network_acl_rule" "this" {
  for_each       = var.network_acl_rule
  network_acl_id = aws_network_acl.this.id

  rule_number     = each.value.rule_number
  egress          = each.value.egress
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = each.value.cidr_block
  ipv6_cidr_block = each.value.ipv6_cidr_block
  from_port       = each.value.from_port
  to_port         = each.value.to_port
}