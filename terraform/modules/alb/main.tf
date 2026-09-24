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


resource "aws_lb_target_group" "api_gateway" {
  name        = "${var.name}-api-gw-${var.environment}"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = merge(
    {
      Name = "${var.name}-api-gateway-tg-${var.environment}"
    },
    var.tags
  )
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway.arn
  }
}