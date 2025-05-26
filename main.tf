provider "aws" {
  region = var.aws_region
}

module "s3_bucket_filter" {
  source     = "./modules/s3_bucket_filter"
  aws_region = var.aws_region
}