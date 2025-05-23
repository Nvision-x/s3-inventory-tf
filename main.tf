module "s3_buckets" {
  source                 = "./modules/s3_buckets"
  aws_region             = "us-east-1"
  inventory_bucket_name  = "my-inventory-bucket"
  inventory_bucket_prefix = "inventory-reports/"
}