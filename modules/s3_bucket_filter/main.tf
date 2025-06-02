resource "null_resource" "list_buckets_by_region" {
  provisioner "local-exec" {
    command = <<EOT
      OUTPUT_FILE="${path.module}/../../buckets.csv"
      echo "bucket_name" > "$OUTPUT_FILE"
      aws s3api list-buckets --query "Buckets[].Name" --output text | tr '\t' '\n' | while read bucket; do
        region=$(aws s3api get-bucket-location --bucket $bucket --query "LocationConstraint" --output text)
        if [[ "$region" == "${var.aws_region}" || ("$region" == "null" && "${var.aws_region}" == "us-east-1") ]]; then
          echo "Bucket in ${var.aws_region}: $bucket"
          echo "$bucket" >> "$OUTPUT_FILE"

          # Check if inventory configuration "terra-s3-inv" exists
          inventory_exists=$(aws s3api list-bucket-inventory-configurations --bucket $bucket --query "InventoryConfigurationList[?Id=='terra-s3-inv'] | length(@)" --output text 2>/dev/null)

          if [[ "$inventory_exists" == "0" ]]; then
            echo "Creating inventory configuration 'terra-s3-inv' for bucket: $bucket"

            aws s3api put-bucket-inventory-configuration --bucket $bucket --id "terra-s3-inv" --inventory-configuration '{
              "Destination": {
                "S3BucketDestination": {
                  "AccountId": "'$(aws sts get-caller-identity --query Account --output text)'",
                  "Bucket": "arn:aws:s3:::'$bucket'",
                  "Format": "CSV"
                }
              },
              "IsEnabled": true,
              "Id": "terra-s3-inv",
              "IncludedObjectVersions": "All",
              "Schedule": {
                "Frequency": "Daily"
              }
            }'
          else
            echo "Inventory configuration 'terra-s3-inv' already exists for $bucket"
          fi
        fi
      done
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
