output "vpc_id" {
  description = "VPC ID"
  type = string
  value = module.vpc.vpc_id
}
