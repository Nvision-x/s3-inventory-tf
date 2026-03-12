terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  bucket_set = toset(var.buckets)

  all_optional_fields = [
    "Size",
    "LastModifiedDate",
    "StorageClass",
    "ETag",
    "IsMultipartUploaded",
    "ReplicationStatus",
    "EncryptionStatus",
    "ObjectLockRetainUntilDate",
    "ObjectLockMode",
    "ObjectLockLegalHoldStatus",
    "IntelligentTieringAccessTier",
    "BucketKeyStatus",
    "ChecksumAlgorithm",
    "ObjectAccessControlList",
    "ObjectOwner"
  ]
}

resource "aws_s3_bucket_policy" "this" {
  for_each = var.manage_bucket_policy ? local.bucket_set : toset([])

  bucket = each.key

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCollectorAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.collector_account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          "arn:aws:s3:::${each.key}",
          "arn:aws:s3:::${each.key}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_inventory" "this" {
  for_each = local.bucket_set

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-${var.region}"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled         = var.enabled
  optional_fields = local.all_optional_fields
}

output "configured_buckets" {
  description = "List of buckets configured in this region"
  value       = keys(aws_s3_bucket_inventory.this)
}

output "inventory_details" {
  description = "Inventory configuration details per bucket"
  value = {
    for bucket_name, config in aws_s3_bucket_inventory.this :
    bucket_name => {
      inventory_id     = config.name
      destination      = config.destination[0].bucket[0].bucket_arn
      collector_bucket = "${var.collector_bucket_prefix}-${var.region}"
      prefix           = config.destination[0].bucket[0].prefix
      frequency        = config.schedule[0].frequency
      enabled          = config.enabled
      region           = var.region
    }
  }
}
