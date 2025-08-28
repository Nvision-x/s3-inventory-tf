variable "aws_region" {
  description = "The AWS region to filter S3 buckets by"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_list_file" {
  description = "Path to file containing bucket names and regions (format: bucket-name region). If empty or file doesn't exist, will use bucket_names variable"
  type        = string
  default     = "buckets.txt"
}

variable "bucket_names" {
  description = "List of S3 bucket names to configure inventory for (used when bucket_list_file is not available)"
  type        = list(string)
  default     = []
}

variable "collector_account_id" {
  description = "The AWS account ID where the collector bucket resides (awsdq account)"
  type        = string
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

variable "source_account_name" {
  description = "The name/alias of the source AWS account (used in inventory path)"
  type        = string
}

variable "inventory_name" {
  description = "Name of the inventory configuration"
  type        = string
  default     = "terra-s3-inv"
}

variable "included_object_versions" {
  description = "Object versions to include in inventory (All or Current)"
  type        = string
  default     = "All"
}

variable "schedule_frequency" {
  description = "Frequency of inventory generation (Daily or Weekly)"
  type        = string
  default     = "Daily"
}

variable "output_format" {
  description = "Output format for inventory files (CSV, ORC, or Parquet)"
  type        = string
  default     = "CSV"
}

variable "enabled" {
  description = "Whether inventory configuration is enabled"
  type        = bool
  default     = true
}