variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "repositories" {
  description = "Repositories list"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "whether image tags can be overwritten"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE, IMMUTABLE_WITH_EXCLUSION, MUTABLE_WITH_EXCLUSION"], var.image_tag_mutability)
    error_message = "image_tag_mutibility must be MUTABLE or IMMUTABLE or MUTABLE_WITH_EXCLUSION or IMMUTABLE_WITH_EXCLUSION"
  }
}

variable "scan_on_push" {
  description = "Enable image vulnerability scanning when images are pushed"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for ECR images"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS."
  }
}

variable "kms_key" {
  description = "KMS Key in case the encryption type is KMS"
  type        = string
  default     = null
}

variable "keep_image_count" {
  description = "Number of images to keep in each repository"
  type        = number
  default     = 30

  validation {
    condition     = var.keep_image_count > 0
    error_message = "keep_image_count must be greater than 0."
  }
}