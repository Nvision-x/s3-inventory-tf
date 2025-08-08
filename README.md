# 📦 Terraform S3 Inventory Configuration Module

This Terraform module automates the process of **identifying all S3 buckets in a specified AWS region** and **applying an Inventory configuration** (`terra-s3-inv`) to each bucket that doesn't already have it.

## 🚀 Purpose

The goal of this module is to provide visibility across your S3 assets by:

- 🔍 **Discovering** all S3 buckets that exist in a specific region OR from a provided bucket list
- 📥 **Generating a CSV report** of those buckets
- 📂 **Uploading the report** as a GitHub Actions artifact
- ✅ **Checking each bucket** for an existing inventory configuration named `terra-s3-inv`
- 🏗️ **Creating the inventory configuration** if it's missing
- 📤 **Delivering inventory reports** to a central destination bucket (`s3-terra-inventory`)

## ⚙️ How It Works

1. **Bucket Discovery**:
   - **File-based**: Reads bucket names and regions from a specified file (if provided and not empty)
   - **Region-based**: Scans all buckets in the specified AWS region (fallback mode)

2. **CSV Output**:
   - Writes the filtered bucket names into a `buckets.csv` file.

3. **Inventory Configuration Check**:
   - For each matching bucket, checks if `terra-s3-inv` inventory exists.
   - If not found, a new configuration is added using `aws s3api put-bucket-inventory-configuration`.

4. **Cross-Bucket Reporting**:
   - Inventory data is stored in a central bucket (`s3-terra-inventory`) for easier aggregation.

## 📎 Requirements

- Terraform >= 1.3.0
- AWS CLI installed (for local-exec commands)
- IAM permissions to list and configure S3 buckets
- Destination bucket (`s3-terra-inventory`) must already exist

## 📁 Outputs

- `buckets.csv` file with all S3 buckets in the selected region
- GitHub Actions artifact for further audit or CI/CD integrations

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

## ✅ Basic Example Usage

```hcl
module "s3_inventory_config" {
  source           = "git::https://github.com/Nvision-x/Terraform-S3-Inventory-Configuration.git?ref=v1.0.0"
  aws_region       = "eu-central-1"
  bucket_list_file = "buckets.txt"  # Optional: if not provided or empty, scans by region
}
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
