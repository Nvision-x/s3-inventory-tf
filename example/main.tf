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

# Call the S3 inventory module
# IMPORTANT: You must pass all 14 provider configurations to the module
module "s3_inventory" {
  source = "../"

  # Pass all required providers to the module
  providers = {
    aws.us_east_1      = aws.us_east_1
    aws.us_east_2      = aws.us_east_2
    aws.us_west_1      = aws.us_west_1
    aws.us_west_2      = aws.us_west_2
    aws.eu_west_1      = aws.eu_west_1
    aws.eu_west_2      = aws.eu_west_2
    aws.eu_central_1   = aws.eu_central_1
    aws.ap_south_1     = aws.ap_south_1
    aws.ap_southeast_1 = aws.ap_southeast_1
    aws.ap_southeast_2 = aws.ap_southeast_2
    aws.ap_northeast_1 = aws.ap_northeast_1
    aws.ap_northeast_2 = aws.ap_northeast_2
    aws.sa_east_1      = aws.sa_east_1
    aws.ca_central_1   = aws.ca_central_1
  }

  # Module configuration
  aws_region              = var.aws_region
  bucket_list_file        = var.bucket_list_file
  collector_account_id    = var.collector_account_id
  collector_bucket_prefix = var.collector_bucket_prefix
  source_account_id       = var.source_account_id
  inventory_name          = "daily-inventory"
  output_format           = "Parquet"
  manage_bucket_policy    = var.manage_bucket_policy
}