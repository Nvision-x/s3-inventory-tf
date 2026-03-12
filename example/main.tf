# Example: how to onboard accounts
#
# 1. Add your account to accounts.json with bucket names and regions
# 2. If your account uses a region not already listed below, add a
#    provider block and a module block for that region
# 3. Run: terraform plan -var="source_account_id=111111111111"
#
# The pipeline runs this once per account — source_account_id is passed
# by the GitHub Actions workflow per account entry in accounts.json.

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  config = jsondecode(file("${path.module}/accounts.json"))

  account = one([
    for a in local.config.accounts : a
    if a.account_id == var.source_account_id
  ])

  buckets_by_region = {
    for region in distinct([for b in local.account.buckets : b.region]) :
    region => [for b in local.account.buckets : b.name if b.region == region]
  }
}

# --- Provider per region (add more as needed) ---

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

# --- Module per region ---

module "us_east_1" {
  source = "../"
  count  = contains(keys(local.buckets_by_region), "us-east-1") ? 1 : 0

  region                  = "us-east-1"
  buckets                 = local.buckets_by_region["us-east-1"]
  collector_account_id    = local.config.collector_account_id
  collector_bucket_prefix = local.config.collector_bucket_prefix
  source_account_id       = var.source_account_id

  providers = {
    aws = aws.us_east_1
  }
}

module "us_east_2" {
  source = "../"
  count  = contains(keys(local.buckets_by_region), "us-east-2") ? 1 : 0

  region                  = "us-east-2"
  buckets                 = local.buckets_by_region["us-east-2"]
  collector_account_id    = local.config.collector_account_id
  collector_bucket_prefix = local.config.collector_bucket_prefix
  source_account_id       = var.source_account_id

  providers = {
    aws = aws.us_east_2
  }
}

# --- Outputs ---

output "configured_buckets" {
  value = concat(
    try(module.us_east_1[0].configured_buckets, []),
    try(module.us_east_2[0].configured_buckets, [])
  )
}

output "bucket_inventory_details" {
  value = merge(
    try(module.us_east_1[0].inventory_details, {}),
    try(module.us_east_2[0].inventory_details, {})
  )
}

output "regions_configured" {
  value = keys(local.buckets_by_region)
}
