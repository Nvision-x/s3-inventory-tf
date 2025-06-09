# 📦 Terraform S3 Inventory Configuration Module

This Terraform module automates the process of **identifying all S3 buckets in a specified AWS region** and **applying an Inventory configuration** (`terra-s3-inv`) to each bucket that doesn't already have it.

---

## 🚀 Purpose

The goal of this module is to provide **visibility and governance** across your S3 assets by:

- 🔍 **Discovering** all S3 buckets that exist in a specific region
- 📥 **Generating a CSV report** of those buckets
- 📂 **Uploading the report** as a GitHub Actions artifact
- ✅ **Checking each bucket** for an existing inventory configuration named `terra-s3-inv`
- 🏗️ **Creating the inventory configuration** if it's missing
- 📤 **Delivering inventory reports** to a central destination bucket (`s3-terra-inventory`)

This is especially useful for compliance, cost tracking, and operational transparency.

---

## ⚙️ How It Works

1. **Local Execution with `null_resource`**:
   - Uses a `local-exec` provisioner to run AWS CLI commands inside Terraform.
   - Filters buckets to include only those within the specified region.

2. **CSV Output**:
   - Writes the filtered bucket names into a `buckets.csv` file.

3. **Inventory Configuration Check**:
   - For each matching bucket, checks if `terra-s3-inv` inventory exists.
   - If not found, a new configuration is added using `aws s3api put-bucket-inventory-configuration`.

4. **Cross-Bucket Reporting**:
   - Inventory data is stored in a central bucket (`s3-terra-inventory`) for easier aggregation.

---

## 📎 Requirements

- Terraform >= 1.3.0
- AWS CLI installed (for local-exec commands)
- IAM permissions to list and configure S3 buckets
- Destination bucket (`s3-terra-inventory`) must already exist

---

## 📁 Outputs

- `buckets.csv` file with all S3 buckets in the selected region
- GitHub Actions artifact for further audit or CI/CD integrations

---

## ✅ Example Usage

```hcl
module "s3_inventory_config" {
  source     = "git::https://github.com/Nvision-x/Terraform-S3-Inventory-Configuration.git?ref=v1.0.0"
  aws_region = "eu-central-1"
}


Inventory Configuration

Field	Required	Description
Id	✅	Unique name for the inventory configuration
IsEnabled	✅	Whether the configuration is active
IncludedObjectVersions	✅	All or Current — includes all versions or just the latest
Destination	✅	Where the inventory report is delivered (another bucket)
Schedule	✅	Frequency: Daily or Weekly
Prefix	❌	Only include objects with this key prefix
Filter	❌	More advanced filter to include only certain objects
OptionalFields	❌	List of metadata fields to include in the report

Optional Fields

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
