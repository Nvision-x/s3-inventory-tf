# S3 Inventory Configuration Module

Terraform module that configures [S3 Inventory](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-inventory.html) on source account buckets, delivering reports to a centralized collector account.

## Architecture

```
Source Account A                    Collector Account (022787320932)
┌──────────────────────┐            ┌─────────────────────────────────┐
│ us-east-1:           │            │                                 │
│   bucket-1 ─────────────────────> │ nvisionx-s3-inventory-us-east-1 │
│   bucket-2 ─────────────────────> │   └── 111111111111/             │
│                      │            │         ├── bucket-1/            │
│ us-east-2:           │            │         └── bucket-2/            │
│   bucket-3 ─────────────────────> │                                 │
└──────────────────────┘            │ nvisionx-s3-inventory-us-east-2 │
                                    │   └── 111111111111/             │
Source Account B                    │         └── bucket-3/            │
┌──────────────────────┐            │                                 │
│ us-east-1:           │            │ nvisionx-s3-inventory-us-east-1 │
│   bucket-x ─────────────────────> │   └── 222222222222/             │
│   bucket-y ─────────────────────> │         ├── bucket-x/           │
└──────────────────────┘            │         └── bucket-y/           │
                                    └─────────────────────────────────┘
```

Each source bucket gets an `aws_s3_bucket_inventory` resource that delivers Parquet reports to a regional collector bucket (`{prefix}-{region}`) in the collector account. The inventory path is organized as `{source_account_id}/{bucket_name}/`.

## Module interface

The module is **single-region** and **provider-free**. Call it once per region, passing the appropriate provider.

### Inputs

| Variable | Type | Required | Default | Description |
|---|---|---|---|---|
| `region` | string | yes | - | AWS region for this module instance |
| `buckets` | list(string) | yes | - | Bucket names in this region |
| `collector_account_id` | string | yes | - | AWS account ID of the collector |
| `source_account_id` | string | yes | - | Source AWS account ID (used as inventory prefix) |
| `collector_bucket_prefix` | string | no | `"nvisionx-s3-inventory"` | Prefix for collector buckets |
| `inventory_name` | string | no | `"terra-s3-inv"` | Name of the inventory configuration |
| `output_format` | string | no | `"Parquet"` | CSV, ORC, or Parquet |
| `schedule_frequency` | string | no | `"Daily"` | Daily or Weekly |
| `included_object_versions` | string | no | `"All"` | All or Current |
| `enabled` | bool | no | `true` | Whether inventory is enabled |
| `manage_bucket_policy` | bool | no | `false` | Whether to add cross-account read policy to source buckets |

### Outputs

| Output | Description |
|---|---|
| `configured_buckets` | List of bucket names with inventory configured |
| `inventory_details` | Map of bucket name to inventory config (inventory_id, destination, collector_bucket, prefix, frequency, enabled, region) |

### Optional fields included

Every inventory report includes these metadata fields: Size, LastModifiedDate, StorageClass, ETag, IsMultipartUploaded, ReplicationStatus, EncryptionStatus, ObjectLockRetainUntilDate, ObjectLockMode, ObjectLockLegalHoldStatus, IntelligentTieringAccessTier, BucketKeyStatus, ChecksumAlgorithm, ObjectAccessControlList, ObjectOwner.

## Quick start

### Minimal usage (single region)

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

### Multi-region

Add one provider + one module block per region:

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

module "inventory_us_east_1" {
  source = "git::https://github.com/Nvision-x/s3-inventory-tf.git?ref=v2025.1"

  region               = "us-east-1"
  buckets              = ["bucket-a", "bucket-b"]
  collector_account_id = "022787320932"
  source_account_id    = "111111111111"

  providers = { aws = aws.us_east_1 }
}

module "inventory_us_east_2" {
  source = "git::https://github.com/Nvision-x/s3-inventory-tf.git?ref=v2025.1"

  region               = "us-east-2"
  buckets              = ["bucket-c"]
  collector_account_id = "022787320932"
  source_account_id    = "111111111111"

  providers = { aws = aws.us_east_2 }
}
```

## Example: JSON-driven multi-account deployment

The [`example/`](example/) directory contains a production-ready setup for managing multiple accounts from a single repo.

### Structure

```
example/
├── accounts.json                    # All accounts, buckets, and backend config
├── main.tf                          # Reads JSON, calls module per region
├── variables.tf                     # Just source_account_id
└── .github/workflows/deploy.yml     # Pipeline: iterates accounts in parallel
```

### accounts.json format

```json
{
  "collector_account_id": "022787320932",
  "collector_bucket_prefix": "nvisionx-s3-inventory",
  "accounts": [
    {
      "account_id": "111111111111",
      "name": "staging",
      "oidc_role": "NxGitHubActionsRole",
      "backend": {
        "bucket": "tf-state-staging-east-2",
        "key": "s3-inventory/terraform.tfstate",
        "region": "us-east-2"
      },
      "buckets": [
        {"name": "my-upload-bucket", "region": "us-east-1"},
        {"name": "my-reports-bucket", "region": "us-east-1"},
        {"name": "my-records-bucket", "region": "us-east-2"}
      ]
    }
  ]
}
```

### How the pipeline works

1. A `matrix` job parses `accounts.json` into a GitHub Actions matrix
2. A `deploy` job runs in parallel for each account
3. Each job assumes the account's OIDC role via `aws-actions/configure-aws-credentials`
4. Runs `terraform init` with the account's backend config (separate state per account)
5. Runs `terraform plan/apply -var="source_account_id=XXXX"`

Credentials come from the pipeline (OIDC), not from the Terraform config. The provider blocks only set the region.

### Onboarding a new account

1. Add an entry to `accounts.json` with the account ID, OIDC role, backend config, and bucket list
2. If the account uses a region not already in `main.tf`, add a provider block and module block for that region
3. Push to main -- the pipeline picks it up automatically

## Requirements

- Terraform >= 1.3.0
- AWS provider >= 4.0
- IAM permissions in source account: `s3:PutInventoryConfiguration`, `s3:PutBucketPolicy` (if `manage_bucket_policy = true`)
- Collector bucket must already exist and accept cross-account inventory delivery
