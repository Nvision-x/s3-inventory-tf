# Variables for the example caller configuration

variable "aws_region" {
  description = "The AWS region to filter S3 buckets by or use as default"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_list_file" {
  description = "Path to file containing bucket names and regions (format: bucket-name region)"
  type        = string
  default     = "buckets.txt"
}

variable "collector_account_id" {
  description = "The AWS account ID where the collector bucket resides (awsdq account)"
  type        = string
  # No default - must be provided
}

variable "collector_bucket_name" {
  description = "The name of the S3 bucket in the collector account to store inventory data"
  type        = string
  default     = "s3-terra-inventory"
}

variable "collector_bucket_region" {
  description = "The AWS region where the collector bucket resides"
  type        = string
  default     = "eu-central-1"
}

# Optional: Environment variable for environment-specific deployments
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

# Source account ID for inventory path organization
variable "source_account_id" {
  description = "The source AWS account ID (used in inventory path: collector-bucket/region/source-account-id/source-bucket/data)"
  type        = string
  # No default - must be provided
}