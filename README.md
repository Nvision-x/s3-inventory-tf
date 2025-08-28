# 📦 S3 Inventory Configuration for Cross-Account Collection

This Terraform module automates S3 inventory collection from multiple AWS accounts and sends the inventory data to a centralized collector bucket.

## 🚀 Purpose

The goal of this module is to provide centralized visibility across S3 assets in multiple AWS accounts by:

- 🔍 **Discovering** all S3 buckets that exist in a specific region OR from a provided bucket list
- 📥 **Generating a CSV report** of those buckets
- ✅ **Checking each bucket** for an existing inventory configuration named `terra-s3-inv`
- 🏗️ **Creating the inventory configuration** if it's missing
- 📤 **Delivering inventory reports** to a central collector bucket

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Source Account │     │  Source Account │     │  Source Account │
│       #1        │     │       #2        │     │       #3        │
│                 │     │                 │     │                 │
│ S3 Buckets:     │     │ S3 Buckets:     │     │ S3 Buckets:     │
│ - bucket-a      │     │ - bucket-x      │     │ - bucket-p      │
│ - bucket-b      │     │ - bucket-y      │     │ - bucket-q      │
│                 │     │                 │     │                 │
│ [Inventory]     │     │ [Inventory]     │     │ [Inventory]     │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │    Collector Account    │
                    │                         │
                    │  Collector Bucket:      │
                    │  s3-terra-inventory     │
                    │                         │
                    │  └── account-1/         │
                    │      └── bucket-a/      │
                    │      └── bucket-b/      │
                    │  └── account-2/         │
                    │      └── bucket-x/      │
                    │      └── bucket-y/      │
                    └─────────────────────────┘
```

## ⚙️ How It Works

1. **Deploy Collector Bucket** (One-time setup in collector account):
   - Creates a central S3 bucket with cross-account permissions
   - Configures bucket policies to accept inventory from source accounts

2. **Deploy Inventory Configuration** (In each source account):
   - **Bucket Discovery**:
     - **File-based**: Reads bucket names and regions from a specified file
     - **Region-based**: Scans all buckets in the specified AWS region (fallback)
   - **Inventory Setup**:
     - Checks if `terra-s3-inv` inventory configuration exists
     - Creates configuration pointing to collector bucket
   - **Cross-Account Delivery**:
     - S3 service handles secure delivery to collector bucket

## 📎 Requirements

- Terraform >= 1.3.0
- AWS CLI installed (for local-exec commands)
- IAM permissions:
  - **Collector account**: Permission to create and manage S3 bucket
  - **Source accounts**: Permission to list and configure S3 inventory
- AWS account IDs:
  - Collector account ID
  - All source account IDs

## 🚀 Setup Instructions

### Step 1: Deploy Collector Bucket in Collector Account

First, set up the centralized collector bucket in your collector account:

```bash
cd collector-bucket/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your source account IDs
terraform init
terraform plan
terraform apply
```

Note the outputs:
- `collector_bucket_name`
- `collector_account_id`

### Step 2: Deploy Inventory Configuration in Each Source Account

For each source account:

1. Configure AWS CLI for the source account:
   ```bash
   aws configure --profile source-account-1
   ```

2. Copy and update the configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars`:
   - Set `collector_account_id` to the collector account ID
   - Set `collector_bucket_name` to match the bucket created in Step 1
   - Configure `aws_region` for the buckets you want to inventory

4. Deploy the configuration:
   ```bash
   AWS_PROFILE=source-account-1 terraform init
   AWS_PROFILE=source-account-1 terraform apply
   ```

5. Repeat for each source account

## 📋 Usage Examples

### 🗂️ File-Based Bucket Configuration

#### 1. Using a Bucket List File

Create a `buckets.txt` file in your project root directory:

```text
# buckets.txt
# Format: bucket-name region
# Lines starting with # are comments

my-production-bucket us-east-1
my-staging-bucket us-west-2
my-eu-bucket eu-central-1
my-asia-bucket ap-southeast-1

# Buckets without region will use the default aws_region variable
my-default-region-bucket
```

Then apply the Terraform configuration:

```bash
terraform init
terraform apply
```

#### 2. Using a Custom File Path

```bash
terraform apply -var="bucket_list_file=./config/production-buckets.txt"
```

#### 3. Using Environment Variables

```bash
export TF_VAR_bucket_list_file="./environments/prod/buckets.txt"
terraform apply
```

#### 4. Using Terraform Variable File

Create a `terraform.tfvars` file:

```hcl
aws_region = "us-west-2"
bucket_list_file = "./buckets-prod.txt"
```

Then run:

```bash
terraform apply
```

### 🌍 Region-Based Scanning (Legacy Mode)

#### 1. Scan All Buckets in a Specific Region

Remove or empty the `buckets.txt` file, then:

```bash
terraform apply -var="aws_region=eu-central-1"
```

#### 2. Using a Non-Existent File (Forces Region Scan)

```bash
terraform apply -var="bucket_list_file=non-existent.txt"
```

#### 3. Multiple Region Deployments

```bash
# Production (us-east-1)
cd environments/prod
terraform apply -var="aws_region=us-east-1" -var="bucket_list_file=prod-buckets.txt"

# Staging (us-west-2)  
cd ../staging
terraform apply -var="aws_region=us-west-2" -var="bucket_list_file=staging-buckets.txt"
```

### 📁 File Format Examples

#### Basic Format
```text
bucket-name-1 us-east-1
bucket-name-2 us-west-2
bucket-name-3 eu-central-1
```

#### With Comments and Empty Lines
```text
# Production buckets
prod-app-data us-east-1
prod-logs us-east-1

# Staging buckets  
staging-app-data us-west-2
staging-logs us-west-2

# EU buckets for GDPR compliance
eu-user-data eu-central-1
```

#### Mixed Format (Some Without Regions)
```text
# These will use the aws_region variable value
main-bucket
backup-bucket

# These have explicit regions
special-us-bucket us-east-1
special-eu-bucket eu-west-1
```

### 🔧 Advanced Configuration

#### Using with Terraform Modules

```hcl
# main.tf
module "s3_inventory" {
  source = "./modules/s3-inventory"
  
  aws_region       = "us-east-1"
  bucket_list_file = var.environment == "prod" ? "buckets-prod.txt" : "buckets-dev.txt"
}
```

#### CI/CD Pipeline Example

```yaml
# .github/workflows/terraform.yml
- name: Apply Terraform with Environment-Specific Buckets
  run: |
    terraform apply -auto-approve \
      -var="aws_region=${{ matrix.region }}" \
      -var="bucket_list_file=./environments/${{ github.ref_name }}/buckets.txt"
```

## ✅ Example terraform.tfvars Files

### For Collector Account

```hcl
# collector-bucket/terraform.tfvars
aws_region = "eu-central-1"
collector_bucket_name = "s3-terra-inventory-collector"
source_account_ids = [
  "111111111111",  # source account 1
  "222222222222",  # source account 2
  "333333333333"   # source account 3
]
environment = "production"
inventory_retention_days = 90
```

### For Source Accounts

```hcl
# terraform.tfvars
aws_region = "eu-central-1"
bucket_list_file = "buckets.txt"  # Optional
collector_account_id = "999999999999"  # collector account ID
collector_bucket_name = "s3-terra-inventory-collector"
collector_bucket_region = "eu-central-1"
```

## 🚨 Important Notes

> **File Priority**: If `buckets.txt` exists and is not empty, it takes precedence over region scanning

> **Region Fallback**: Buckets without specified regions use the `aws_region` variable

> **Error Handling**: Invalid bucket names or inaccessible regions will cause the operation to fail

> **Permissions**: Ensure your AWS credentials have access to all specified buckets and regions

## Inventory Configuration

| Field | Required | Description |
|:--|:--:|:--|
| Id | ✅ | Unique name for the inventory configuration |
| IsEnabled | ✅ | Whether the configuration is active |
| IncludedObjectVersions | ✅ | All or Current — includes all versions or just the latest |
| Destination | ✅ | Where the inventory report is delivered (another bucket) |
| Schedule | ✅ | Frequency: Daily or Weekly |
| Prefix | ❌ | Only include objects with this key prefix |
| Filter | ❌ | More advanced filter to include only certain objects |
| OptionalFields | ❌ | List of metadata fields to include in the report |

## Optional Fields
```
"OptionalFields": 
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
  "ChecksumAlgorithm"
```
