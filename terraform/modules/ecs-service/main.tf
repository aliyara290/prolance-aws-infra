resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn

  desired_count = var.desired_count
  launch_type   = "FARGATE"

  platform_version       = var.platform_version
  enable_execute_command = false

  health_check_grace_period_seconds  = var.target_group_arn != null ? var.health_check_grace_period_seconds : null
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_health_percent

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker_enabled
    rollback = var.deployment_circuit_breaker_rollback
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []

    content {
      target_group_arn = var.target_group_arn
      container_name   = values(var.container_definitions)[0].container_name
      container_port   = values(var.container_definitions)[0].port_mappings[0].container_port
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.service_name
    }
  )
}
