variable "buckets" {
  description = "Set of bucket names to configure inventory for"
  type        = set(string)
}

variable "region" {
  description = "AWS region for the buckets"
  type        = string
}

variable "inventory_name" {
  description = "Name of the inventory configuration"
  type        = string
  default     = "terra-s3-inv"
}

variable "included_object_versions" {
  description = "Object versions to include in inventory"
  type        = string
  default     = "All"
}

variable "schedule_frequency" {
  description = "Frequency of inventory generation"
  type        = string
  default     = "Daily"
}

variable "output_format" {
  description = "Output format for inventory files"
  type        = string
  default     = "CSV"
}

variable "collector_bucket_name" {
  description = "Name of the S3 bucket to store inventory files"
  type        = string
}

variable "collector_account_id" {
  description = "AWS Account ID where the collector bucket resides"
  type        = string
}

variable "source_account_id" {
  description = "Source AWS account ID"
  type        = string
}

variable "enabled" {
  description = "Whether inventory configuration is enabled"
  type        = bool
  default     = true
}