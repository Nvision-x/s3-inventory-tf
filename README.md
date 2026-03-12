# S3 Inventory Configuration Module

Terraform module that configures S3 inventory reporting on source account buckets, delivering reports to a centralized collector account.

## How it works

```
Source Account (us-east-1)          Collector Account
┌──────────────────────┐            ┌──────────────────────────┐
│ bucket-a ──inventory──┼──────────>│ s3-inventory-us-east-1/  │
│ bucket-b ──inventory──┼──────────>│   111111111111/          │
└──────────────────────┘            │     bucket-a/            │
                                    │     bucket-b/            │
Source Account (us-east-2)          │                          │
┌──────────────────────┐            │ s3-inventory-us-east-2/  │
│ bucket-c ──inventory──┼──────────>│   111111111111/          │
└──────────────────────┘            │     bucket-c/            │
                                    └──────────────────────────┘
```

Each source bucket gets an inventory configuration that delivers Parquet reports to a regional collector bucket (`{prefix}-{region}`) in the collector account.

## Module interface

The module is single-region and provider-free. The caller passes a provider and a list of buckets for that region.

### Inputs

- `region` (string) - AWS region for this module instance
- `buckets` (list of strings) - bucket names in this region
- `collector_account_id` (string) - AWS account ID of the collector
- `source_account_id` (string) - source AWS account ID (used as inventory prefix)
- `collector_bucket_prefix` (string, default: `"nvisionx-s3-inventory"`) - prefix for collector buckets
- `inventory_name` (string, default: `"terra-s3-inv"`) - name of the inventory configuration
- `output_format` (string, default: `"Parquet"`) - CSV, ORC, or Parquet
- `schedule_frequency` (string, default: `"Daily"`) - Daily or Weekly
- `included_object_versions` (string, default: `"All"`) - All or Current
- `enabled` (bool, default: `true`) - whether inventory is enabled
- `manage_bucket_policy` (bool, default: `false`) - whether to add cross-account read policy to source buckets

### Outputs

- `configured_buckets` - list of bucket names configured
- `inventory_details` - map of bucket name to inventory config details

## Usage

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "inventory_us_east_1" {
  source = "git::https://github.com/Nvision-x/s3-inventory-tf.git?ref=v2025.1"

  region                  = "us-east-1"
  buckets                 = ["my-bucket-1", "my-bucket-2"]
  collector_account_id    = "022787320932"
  collector_bucket_prefix = "nvisionx-s3-inventory"
  source_account_id       = "111111111111"

  providers = {
    aws = aws.us_east_1
  }
}
```

For a complete multi-account, multi-region setup with JSON config and a CI/CD pipeline, see the [example/](example/) directory.

## Example

The `example/` directory contains a full working deployment:

- `accounts.json` - define accounts, buckets, and backend config
- `main.tf` - reads JSON, calls the module once per region
- `variables.tf` - just `source_account_id`
- `.github/workflows/deploy.yml` - GitHub Actions pipeline that iterates accounts in parallel via OIDC

Customer workflow:
1. Copy `example/` into your repo
2. Update `source` in `main.tf` to point at a release tag
3. Add your accounts and buckets to `accounts.json`
4. Run `terraform plan -var="source_account_id=XXXX"`
