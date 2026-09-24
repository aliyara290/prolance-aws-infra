resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.environment}/${var.service_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "/ecs/${var.environment}/${var.service_name}"
    }
  )
}