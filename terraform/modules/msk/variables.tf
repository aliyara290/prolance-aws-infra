variable "cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version to use"
  type        = string
  default     = "3.7.x"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes in the cluster"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type for the MSK brokers"
  type        = string
  default     = "kafka.t3.small"
}

variable "client_subnets" {
  description = "List of subnets for the MSK cluster"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security groups for the MSK cluster"
  type        = list(string)
}

variable "volume_size" {
  description = "Size in GB of the EBS volume for the data drive on each broker node"
  type        = number
  default     = 20
}
