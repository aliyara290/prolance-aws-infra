resource "aws_ecs_task_definition" "this" {
  family = var.service_name

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = var.cpu
  memory = var.memory

  task_role_arn        = aws_iam_role.execution.arn
  execution_role_arn = aws_iam_role.task.arn

  container_definitions = jsonencode(
    [
      for container in values(var.container_definitions) : {
        name      = container.container_name
        image     = container.container_image
        essential = container.essential

        portMapping = [
          for port in container.port_mappings : {
            name         = port.name
            continerPort = port.container_port
            hostPort     = port.host_port
            protocol     = port.protocol
          }
        ]

        environment = [
          for name, value in container.environment_variables : {
            name  = name
            value = value
          }
        ]

        secrets = [
          for name, arn in container.secrets_arn : {
            name      = name
            valueFrom = arn
          }
        ]

        logConfiguration = {
          logDriver = "awslogs"

          options = {
            "awslog-group"          = container.aws_log_group
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = container.container_name
          }
        }
      }
    ]
  )

  tags = merge(
    {
      Name = "Prolance-${var.environment}-${var.service_name}-task-definition"
    },
    var.tags
  )

}
