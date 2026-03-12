variable "region" {
  description = "AWS region for this module instance"
  type        = string
}

variable "buckets" {
  description = "List of S3 bucket names in this region"
  type        = list(string)
}

variable "collector_account_id" {
  description = "The AWS account ID where the collector bucket resides"
  type        = string
}

variable "collector_bucket_prefix" {
  description = "The prefix for regional collector buckets (e.g., 'nvisionx-s3-inventory' creates 'nvisionx-s3-inventory-us-east-1')"
  type        = string
  default     = "nvisionx-s3-inventory"
}

variable "source_account_id" {
  description = "The source AWS account ID (used as prefix in inventory destination)"
  type        = string
}

variable "inventory_name" {
  description = "Name of the inventory configuration"
  type        = string
  default     = "terra-s3-inv"
}

variable "output_format" {
  description = "Output format for inventory files (CSV, ORC, or Parquet)"
  type        = string
  default     = "Parquet"
}

variable "schedule_frequency" {
  description = "Frequency of inventory generation (Daily or Weekly)"
  type        = string
  default     = "Daily"
}

variable "included_object_versions" {
  description = "Object versions to include in inventory (All or Current)"
  type        = string
  default     = "All"
}

variable "enabled" {
  description = "Whether inventory configuration is enabled"
  type        = bool
  default     = true
}

variable "manage_bucket_policy" {
  description = "Whether to manage S3 bucket policies for cross-account access"
  type        = bool
  default     = false
}
