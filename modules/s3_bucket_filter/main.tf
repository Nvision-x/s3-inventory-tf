resource "null_resource" "list_buckets_by_region" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Fetching buckets in region: ${var.aws_region}"
      aws s3api list-buckets --query "Buckets[].Name" --output text | tr '\t' '\n' | while read bucket; do
        region=$(aws s3api get-bucket-location --bucket $bucket --query "LocationConstraint" --output text)
        # Adjust for us-east-1 which returns "null"
        if [[ "$region" == "${var.aws_region}" || ("$region" == "null" && "${var.aws_region}" == "us-east-1") ]]; then
          echo "Bucket in ${var.aws_region}: $bucket"
        fi
      done
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
