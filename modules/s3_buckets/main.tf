provider "aws" {
  region = var.aws_region
}

data "aws_s3_buckets" "all" {}

resource "aws_s3_bucket_inventory" "inventory" {
  for_each = toset(data.aws_s3_buckets.all.names)

  bucket = each.key
  name   = "inventory-${each.key}"

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = "arn:aws:s3:::${var.inventory_bucket_name}"
      prefix     = "${var.inventory_bucket_prefix}${each.key}/"

      encryption {
        sse_s3 = true
      }
    }
  }

  included_object_versions = "All"
  enabled                  = true
  schedule {
    frequency = "Daily"
  }

  optional_fields = [
    "Size",
    "LastModifiedDate",
    "StorageClass",
    "ETag",
    "IsMultipartUploaded",
    "ReplicationStatus",
    "EncryptionStatus",
    "ObjectLockRetainUntilDate",
    "ObjectLockMode",
    "ObjectLockLegalHoldStatus"
  ]
}

