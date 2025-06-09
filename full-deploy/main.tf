module "s3_inventory_config" {
  source = "git::https://github.com/Nvision-x/Terraform-S3-Inventory-Configuration.git?ref=v1.0.0"

  aws_region = var.aws_region
}