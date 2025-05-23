module "s3_buckets" {
  source     = "./modules/s3_buckets"
  aws_region = "us-east-1" # Change to your desired region
}