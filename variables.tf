variable "aws_region" {
  description = "The AWS region to filter S3 buckets by"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_list_file" {
  description = "Path to file containing bucket names and regions (format: bucket-name region). If empty or file doesn't exist, will scan by region"
  type        = string
  default     = "buckets.txt"
}