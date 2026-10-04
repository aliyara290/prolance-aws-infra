variable "environment" {
  type        = string
  description = "Environment name"
}

variable "bucket_name" {
  type        = string
  description = "S3 Bucket name"
}

variable "bucket_id" {
  type        = string
  description = "S3 Bucket ID"
}

variable "bucket_arn" {
  type        = string
  description = "S3 Bucket ARN"
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "S3 Bucket Regional Domain Name"
}

variable "aliases" {
  type        = list(string)
  description = "List of custom domain names for CloudFront"
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate for custom domains"
  default     = null
}
