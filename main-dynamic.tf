terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
      configuration_aliases = [
        aws.us_east_1,
        aws.us_east_2,
        aws.us_west_1,
        aws.us_west_2,
        aws.eu_west_1,
        aws.eu_west_2,
        aws.eu_central_1,
        aws.ap_south_1,
        aws.ap_southeast_1,
        aws.ap_southeast_2,
        aws.ap_northeast_1,
        aws.ap_northeast_2,
        aws.sa_east_1,
        aws.ca_central_1
      ]
    }
  }
}

locals {
  # Read bucket list file and parse bucket names with their regions
  # Each S3 bucket will send inventory to a regional collector bucket in the same region
  # For example: bucket in us-east-1 → nvisionx-s3-inventory-us-east-1
  bucket_list_content = fileexists(var.bucket_list_file) ? file(var.bucket_list_file) : ""

  bucket_entries_from_file = local.bucket_list_content != "" ? [
    for line in split("\n", local.bucket_list_content) :
    {
      bucket_name   = trimspace(split(" ", line)[0])
      bucket_region = length(split(" ", line)) > 1 ? trimspace(split(" ", line)[1]) : var.aws_region
    }
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
  ] : []
  
  # Check if we should enable bucket discovery
  # Discovery is enabled when:
  # 1. enable_bucket_discovery is true
  # 2. No valid bucket entries in file (only comments or empty)
  # 3. No bucket_names provided via variable
  should_discover = var.enable_bucket_discovery && length(local.bucket_entries_from_file) == 0 && length(var.bucket_names) == 0
}

data "external" "discover_buckets" {
  count = local.should_discover ? 1 : 0
  
  program = ["bash", "${path.module}/scripts/discover-buckets.sh"]
  
  query = {
    regions = join(",", var.discovery_regions)
  }
}

locals {
  bucket_map_from_file = {
    for entry in local.bucket_entries_from_file :
    entry.bucket_name => entry.bucket_region
  }

  bucket_map_from_variable = {
    for bucket in var.bucket_names :
    bucket => var.aws_region
  }
  
  # Discovered buckets from external data source
  bucket_map_from_discovery = try(data.external.discover_buckets[0].result, {})

  # Priority: file > variable > discovery
  all_buckets_to_configure = length(local.bucket_map_from_file) > 0 ? local.bucket_map_from_file : (
    length(local.bucket_map_from_variable) > 0 ? local.bucket_map_from_variable : local.bucket_map_from_discovery
  )

  buckets_by_region = {
    for bucket, region in local.all_buckets_to_configure :
    region => bucket...
  }

  unique_regions = toset(values(local.all_buckets_to_configure))
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu_west_2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "ap_southeast_2"
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "ap_northeast_1"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "ap_northeast_2"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "sa_east_1"
  region = "sa-east-1"
}

provider "aws" {
  alias  = "ca_central_1"
  region = "ca-central-1"
}

resource "aws_s3_bucket_inventory" "us_east_1" {
  for_each = contains(keys(local.buckets_by_region), "us-east-1") ? toset(local.buckets_by_region["us-east-1"]) : toset([])
  provider = aws.us_east_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-us-east-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "us_east_2" {
  for_each = contains(keys(local.buckets_by_region), "us-east-2") ? toset(local.buckets_by_region["us-east-2"]) : toset([])
  provider = aws.us_east_2

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-us-east-2"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "us_west_1" {
  for_each = contains(keys(local.buckets_by_region), "us-west-1") ? toset(local.buckets_by_region["us-west-1"]) : toset([])
  provider = aws.us_west_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-us-west-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "us_west_2" {
  for_each = contains(keys(local.buckets_by_region), "us-west-2") ? toset(local.buckets_by_region["us-west-2"]) : toset([])
  provider = aws.us_west_2

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-us-west-2"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "eu_west_1" {
  for_each = contains(keys(local.buckets_by_region), "eu-west-1") ? toset(local.buckets_by_region["eu-west-1"]) : toset([])
  provider = aws.eu_west_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-eu-west-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "eu_west_2" {
  for_each = contains(keys(local.buckets_by_region), "eu-west-2") ? toset(local.buckets_by_region["eu-west-2"]) : toset([])
  provider = aws.eu_west_2

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-eu-west-2"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "eu_central_1" {
  for_each = contains(keys(local.buckets_by_region), "eu-central-1") ? toset(local.buckets_by_region["eu-central-1"]) : toset([])
  provider = aws.eu_central_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-eu-central-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "ap_south_1" {
  for_each = contains(keys(local.buckets_by_region), "ap-south-1") ? toset(local.buckets_by_region["ap-south-1"]) : toset([])
  provider = aws.ap_south_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-ap-south-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "ap_southeast_1" {
  for_each = contains(keys(local.buckets_by_region), "ap-southeast-1") ? toset(local.buckets_by_region["ap-southeast-1"]) : toset([])
  provider = aws.ap_southeast_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-ap-southeast-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "ap_southeast_2" {
  for_each = contains(keys(local.buckets_by_region), "ap-southeast-2") ? toset(local.buckets_by_region["ap-southeast-2"]) : toset([])
  provider = aws.ap_southeast_2

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-ap-southeast-2"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "ap_northeast_1" {
  for_each = contains(keys(local.buckets_by_region), "ap-northeast-1") ? toset(local.buckets_by_region["ap-northeast-1"]) : toset([])
  provider = aws.ap_northeast_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-ap-northeast-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "ap_northeast_2" {
  for_each = contains(keys(local.buckets_by_region), "ap-northeast-2") ? toset(local.buckets_by_region["ap-northeast-2"]) : toset([])
  provider = aws.ap_northeast_2

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-ap-northeast-2"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "sa_east_1" {
  for_each = contains(keys(local.buckets_by_region), "sa-east-1") ? toset(local.buckets_by_region["sa-east-1"]) : toset([])
  provider = aws.sa_east_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-sa-east-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

resource "aws_s3_bucket_inventory" "ca_central_1" {
  for_each = contains(keys(local.buckets_by_region), "ca-central-1") ? toset(local.buckets_by_region["ca-central-1"]) : toset([])
  provider = aws.ca_central_1

  bucket = each.key
  name   = var.inventory_name

  included_object_versions = var.included_object_versions

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.output_format
      bucket_arn = "arn:aws:s3:::${var.collector_bucket_prefix}-ca-central-1"
      account_id = var.collector_account_id
      prefix     = var.source_account_id
    }
  }

  enabled = var.enabled
}

output "configured_buckets" {
  description = "List of S3 buckets with inventory configurations"
  value       = keys(local.all_buckets_to_configure)
}

output "bucket_inventory_details" {
  description = "Detailed inventory configuration for each bucket"
  value = merge(
    {
      for bucket_name, config in aws_s3_bucket_inventory.us_east_1 :
      bucket_name => {
        inventory_id      = config.name
        destination       = config.destination[0].bucket[0].bucket_arn
        collector_bucket  = "${var.collector_bucket_prefix}-us-east-1"
        prefix            = config.destination[0].bucket[0].prefix
        frequency         = config.schedule[0].frequency
        enabled           = config.enabled
        region            = "us-east-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.us_east_2 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "us-east-2"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.us_west_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "us-west-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.us_west_2 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "us-west-2"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.eu_west_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "eu-west-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.eu_west_2 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "eu-west-2"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.eu_central_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "eu-central-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.ap_south_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "ap-south-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.ap_southeast_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "ap-southeast-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.ap_southeast_2 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "ap-southeast-2"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.ap_northeast_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "ap-northeast-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.ap_northeast_2 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "ap-northeast-2"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.sa_east_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "sa-east-1"
      }
    },
    {
      for bucket_name, config in aws_s3_bucket_inventory.ca_central_1 :
      bucket_name => {
        inventory_id = config.name
        destination  = config.destination[0].bucket[0].bucket_arn
        prefix       = config.destination[0].bucket[0].prefix
        frequency    = config.schedule[0].frequency
        enabled      = config.enabled
        region       = "ca-central-1"
      }
    }
  )
}

output "regions_configured" {
  description = "List of AWS regions where inventory configurations are applied"
  value       = local.unique_regions
}