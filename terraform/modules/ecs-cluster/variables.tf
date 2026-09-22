variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS Cluster name"
  type = string
}

variable "container_insights" {
  description = "Enable cloud watch monitoring"
  type = bool
  default = true
}

variable "tags" {
  description = "Additional tags"
  type = map(string)
  default = {}
}