variable "bucket_names" {
  description = "List of S3 bucket names to check and configure inventory for"
  type        = list(string)
}

variable "aws_region" {
  description = "Region to match buckets against"
  type        = string
}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  bucket   = each.key
}

locals {
  filtered_buckets = {
    for k, v in data.aws_s3_bucket.buckets :
    k => v if v.region == var.aws_region
  }
}

resource "aws_s3_bucket_inventory" "inventory_config" {
  for_each = local.filtered_buckets

  bucket = each.key
  name   = "terra-s3-inv"

  included_object_versions = "All"
  enabled                  = true

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = "arn:aws:s3:::s3-terra-inventory"
      account_id = data.aws_caller_identity.current.account_id
    }
  }
}
