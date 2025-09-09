
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

module "s3_inventory" {
  source = "git::https://github.com/Nvision-x/s3-inventory-tf.git?ref=v1.1.0"
  aws_region = var.aws_region
  bucket_list_file = var.bucket_list_file
  collector_account_id    = var.collector_account_id
  collector_bucket_prefix = var.collector_bucket_prefix 
  source_account_id = var.source_account_id
  inventory_name    = "daily-inventory"
  output_format     = "Parquet"
}