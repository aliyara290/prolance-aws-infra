variable "aws_region" {
  description = "AWS region where the Terraform state bucket will be created."
  type        = string
  default     = "eu-west-3"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store Terraform state."
  type        = string
  default     = "my-terraform-state-bucket-290"
}