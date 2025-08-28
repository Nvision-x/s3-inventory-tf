terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_s3_bucket_inventory" "inventory_config" {
  for_each = var.buckets

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_name}"
      account_id = var.collector_account_id
      prefix     = "${var.region}/${var.source_account_id}/${each.key}/data"
    }
  }

  enabled = var.enabled
}