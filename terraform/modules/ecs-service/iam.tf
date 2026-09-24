resource "aws_iam_role" "execution" {
  name = "${var.service_name}-execution-role"

  assume_role_policy = jsonencode([
    {
        Version = "2012-10-17"

        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    }
  ])
}

resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${var.service_name}-task-role"

  assume_role_policy = jsonencode([
    {
        Version = "2012-10-17"

        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    }
  ])
}

resource "aws_iam_role_policy" "task" {
  count = length(var.additional_task_policy_statements) > 0 ? 1 : 0

  name = "${var.service_name}-additional-policy"

  role = aws_iam_role.task.name

  policy = jsonencode(
    {
        Version = "2012-10-17"
        Statement = var.additional_task_policy_statements
    }
  )
}