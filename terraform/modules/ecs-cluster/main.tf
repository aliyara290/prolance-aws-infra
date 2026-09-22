resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  setting {
    name = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    {
        Name = "Prolance-${var.environment}-cluster"
    }, 
    var.tags
  )
}