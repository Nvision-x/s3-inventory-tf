provider "aws" {
  region = var.aws_region
}

data "aws_s3_buckets" "all" {}

resource "null_resource" "print_bucket_names" {
  for_each = toset(data.aws_s3_buckets.all.names)

  provisioner "local-exec" {
    command = "echo Bucket: ${each.key}"
  }
}
