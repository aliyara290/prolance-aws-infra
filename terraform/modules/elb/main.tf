resource "aws_lb" "this" {
  name               = "${var.name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"

  security_groups = var.security_group_ids
  subnets         = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    {
      Name = "${var.name}-${var.environment}"
    },
    var.tags
  )
}


resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = "${var.name}-${each.key}-${var.environment}"
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = each.value.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = each.value.protocol
    path                = each.value.health_check_path
    port                = "traffic-port"
    healthy_threshold   = each.value.healthy_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
    timeout             = each.value.health_check_timeout
    interval            = each.value.health_check_interval
    matcher             = each.value.health_check_matcher
  }

  tags = merge(
    {
      Name = "${var.name}-${each.key}-tg-${var.environment}"
    },
    var.tags
  )
}


resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  ssl_policy      = each.value.protocol == "HTTPS" ? each.value.ssl_policy : null
  certificate_arn = each.value.certificate_arn

  default_action {
    type             = each.value.action_type
    target_group_arn = each.value.action_type == "forward" ? aws_lb_target_group.this[each.value.target_group_key].arn : null

    dynamic "redirect" {
      for_each = each.value.action_type == "redirect" ? [1] : []

      content {
        port        = each.value.redirect_port
        protocol    = each.value.redirect_protocol
        status_code = each.value.redirect_status_code
      }
    }
  }
}


resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.this[each.value.listener_key].arn
  priority     = each.value.priority

  action {
    type             = each.value.action_type
    target_group_arn = each.value.action_type == "forward" ? aws_lb_target_group.this[each.value.target_group_key].arn : null

    dynamic "redirect" {
      for_each = each.value.action_type == "redirect" ? [1] : []

      content {
        port        = each.value.redirect_port
        protocol    = each.value.redirect_protocol
        status_code = each.value.redirect_status_code
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.action_type == "fixed-response" ? [1] : []

      content {
        content_type = each.value.fixed_response_content_type
        message_body = each.value.fixed_response_message_body
        status_code  = each.value.fixed_response_status_code
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.path_patterns != null ? [1] : []

    content {
      path_pattern {
        values = each.value.path_patterns
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.host_headers != null ? [1] : []

    content {
      host_header {
        values = each.value.host_headers
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.http_request_methods != null ? [1] : []

    content {
      http_request_method {
        values = each.value.http_request_methods
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.source_ips != null ? [1] : []

    content {
      source_ip {
        values = each.value.source_ips
      }
    }
  }

  tags = var.tags
}