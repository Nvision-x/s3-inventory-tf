# S3 Inventory Module - Example Caller Configuration

This directory contains an example of how to use the S3 inventory Terraform module in your own infrastructure.

## 📁 Files in this Example

- **main.tf** - Main Terraform configuration that calls the S3 inventory module
- **variables.tf** - Variable definitions for the caller configuration
- **terraform.tfvars.example** - Example variable values (copy to terraform.tfvars)
- **buckets.txt.example** - Example bucket list file (copy to buckets.txt)

## 🚀 Quick Start

### 1. Copy Example Files

```bash
# Copy the example files to create your actual configuration
cp terraform.tfvars.example terraform.tfvars
cp buckets.txt.example buckets.txt
```

### 2. Update Configuration

Edit `terraform.tfvars` with your actual values:

```hcl
# Your AWS region
aws_region = "us-east-1"

# Your collector account ID
collector_account_id = "999999999999"

# Your collector bucket name
collector_bucket_name = "my-s3-inventory-collector"

# Path to your bucket list
bucket_list_file = "buckets.txt"
```

### 3. Customize Bucket List

Edit `buckets.txt` with your actual S3 buckets:

```text
my-production-bucket us-east-1
my-staging-bucket us-west-2
my-eu-bucket eu-central-1
```

### 4. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## 📝 Usage Scenarios

### Scenario 1: Single Region with Bucket List

```hcl
module "s3_inventory" {
  source = "../"
  
  aws_region              = "us-east-1"
  bucket_list_file        = "buckets.txt"
  collector_account_id    = "999999999999"
  collector_bucket_name   = "s3-inventory-collector"
  collector_bucket_region = "us-east-1"
}
```

### Scenario 2: Multiple Regions

```hcl
module "s3_inventory_us" {
  source = "../"
  
  aws_region              = "us-east-1"
  bucket_list_file        = "buckets-us.txt"
  collector_account_id    = var.collector_account_id
  collector_bucket_name   = var.collector_bucket_name
  collector_bucket_region = var.collector_bucket_region
}

module "s3_inventory_eu" {
  source = "../"
  
  aws_region              = "eu-central-1"
  bucket_list_file        = "buckets-eu.txt"
  collector_account_id    = var.collector_account_id
  collector_bucket_name   = var.collector_bucket_name
  collector_bucket_region = var.collector_bucket_region
}
```

### Scenario 3: Environment-Based Configuration

```hcl
module "s3_inventory" {
  source = "../"
  
  aws_region = var.aws_region
  
  # Different bucket lists per environment
  bucket_list_file = var.environment == "production" ? 
    "buckets-prod.txt" : "buckets-dev.txt"
  
  # Different collector buckets per environment  
  collector_account_id    = var.collector_account_id
  collector_bucket_name   = "${var.environment}-s3-inventory"
  collector_bucket_region = var.collector_bucket_region
}
```

### Scenario 4: Region Scanning (No Bucket List)

```hcl
module "s3_inventory" {
  source = "../"
  
  aws_region = "us-east-1"
  
  # Empty string or non-existent file triggers region scan
  bucket_list_file = ""
  
  collector_account_id    = var.collector_account_id
  collector_bucket_name   = var.collector_bucket_name
  collector_bucket_region = var.collector_bucket_region
}
```

## 🔧 Advanced Configuration

### Using with CI/CD

```yaml
# .github/workflows/deploy.yml
- name: Deploy S3 Inventory
  run: |
    cd example-caller
    terraform init
    terraform apply -auto-approve \
      -var="aws_region=${{ env.AWS_REGION }}" \
      -var="collector_account_id=${{ secrets.COLLECTOR_ACCOUNT_ID }}"
```

### Using with Terragrunt

```hcl
# terragrunt.hcl
terraform {
  source = "../..//s3-inventory-tf"
}

inputs = {
  aws_region              = "us-east-1"
  bucket_list_file        = "buckets.txt"
  collector_account_id    = get_env("COLLECTOR_ACCOUNT_ID")
  collector_bucket_name   = "s3-inventory-collector"
  collector_bucket_region = "us-east-1"
}
```

## 📋 Bucket List File Format

The `buckets.txt` file supports the following format:

```text
# Comment lines start with #
bucket-name-1 us-east-1
bucket-name-2 us-west-2
bucket-name-3 eu-central-1

# Buckets without regions use aws_region default
bucket-without-region

# Empty lines are ignored

# Mix of buckets with and without regions
specific-region-bucket ap-southeast-1
default-region-bucket
```

## 🚨 Important Notes

1. **Permissions**: Ensure your AWS credentials have permissions to:
   - List S3 buckets
   - Configure S3 inventory
   - Access the specified buckets

2. **Collector Bucket**: The collector bucket must:
   - Already exist in the collector account
   - Have proper cross-account permissions
   - Accept inventory from your source account

3. **File Priority**: If `buckets.txt` exists and contains buckets, it takes precedence over region scanning

4. **Region Defaults**: Buckets without explicit regions in the file will use the `aws_region` variable value

## 🆘 Troubleshooting

### Issue: "Bucket not found" error
- Verify the bucket name is correct
- Check you have permissions to access the bucket
- Ensure the region is specified correctly

### Issue: "Permission denied" when creating inventory
- Verify the collector bucket has cross-account permissions
- Check your IAM role has S3 inventory permissions
- Ensure the collector_account_id is correct

### Issue: Module not found
- Check the source path in main.tf points to the correct module location
- Run `terraform init` to download the module

## 📚 Further Reading

- [S3 Inventory Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-inventory.html)
- [Terraform Module Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [Cross-Account S3 Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html)