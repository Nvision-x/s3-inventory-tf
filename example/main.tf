# Example Terraform configuration that calls the S3 inventory module
# This demonstrates how to use the module in your own Terraform projects

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  # Optional: Use AWS profile for authentication
  # profile = "aws01"

  # Optional: Assume role configuration
  # assume_role {
  #   role_arn = "arn:aws:iam::${var.source_account_id}:role/TerraformRole"
  # }
}

# Call the S3 inventory module
module "s3_inventory" {
  source = "../" # Path to the s3-inventory-tf module

  # AWS region to scan for buckets or default region for buckets in file
  aws_region = var.aws_region

  # Path to file containing bucket names and regions
  # If empty or file doesn't exist, will scan all buckets in aws_region
  bucket_list_file = var.bucket_list_file

  # Collector account configuration (awsdq account)
  collector_account_id    = var.collector_account_id
  collector_bucket_name   = var.collector_bucket_name
  collector_bucket_region = var.collector_bucket_region

  # Source account ID for inventory path organization
  source_account_id = var.source_account_id
}

# Example: Multiple region deployments
# Uncomment to deploy inventory for multiple regions

# module "s3_inventory_us_east_1" {
#   source = "../"
#   
#   aws_region              = "us-east-1"
#   bucket_list_file        = "buckets-us-east-1.txt"
#   collector_account_id    = var.collector_account_id
#   collector_bucket_name   = var.collector_bucket_name
#   collector_bucket_region = var.collector_bucket_region
#   source_account_id       = var.source_account_id
# }
# 
# module "s3_inventory_eu_west_1" {
#   source = "../"
#   
#   aws_region              = "eu-west-1"
#   bucket_list_file        = "buckets-eu-west-1.txt"
#   collector_account_id    = var.collector_account_id
#   collector_bucket_name   = var.collector_bucket_name
#   collector_bucket_region = var.collector_bucket_region
#   source_account_id       = var.source_account_id
# }

# Example: Environment-specific deployments
# Uncomment to use different configurations per environment

# module "s3_inventory_env" {
#   source = "../"
#   
#   aws_region = var.aws_region
#   
#   # Use different bucket lists per environment
#   bucket_list_file = var.environment == "production" ? "buckets-prod.txt" : "buckets-dev.txt"
#   
#   # Use different collector buckets per environment
#   collector_account_id    = var.collector_account_id
#   collector_bucket_name   = "${var.environment}-s3-inventory"
#   collector_bucket_region = var.collector_bucket_region
#   source_account_id       = var.source_account_id
# }