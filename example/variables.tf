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
  description = "The AWS account ID where the collector bucket resides"
  type        = string
  # No default - must be provided
}

variable "collector_bucket_prefix" {
  description = "The prefix for regional collector buckets (e.g., 'nvisionx-s3-inventory' creates 'nvisionx-s3-inventory-us-east-1')"
  type        = string
  default     = "nvisionx-s3-inventory"
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