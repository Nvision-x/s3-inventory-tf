variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "inventory_bucket_name" {
  description = "The bucket to store inventory reports"
  type        = string
}

variable "inventory_bucket_prefix" {
  description = "Prefix path within the inventory bucket"
  type        = string
  default     = "inventory/"
}