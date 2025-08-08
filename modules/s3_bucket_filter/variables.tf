variable "aws_region" {
  description = "AWS region to filter S3 buckets by"
  type        = string
}

variable "bucket_list_file" {
  description = "Path to file containing bucket names and regions"
  type        = string
}