#!/bin/bash

# This script discovers S3 buckets in specified regions
# Output format: JSON with bucket names mapped to their regions

set -e

# Parse input JSON from Terraform external data source
eval "$(jq -r '@sh "REGIONS=\(.regions)"')"

# If no regions specified, default to us-east-1
REGIONS="${REGIONS:-us-east-1}"

# Initialize JSON object
echo -n '{'

# List all buckets once
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text 2>/dev/null || echo "")

first=true
for bucket in $buckets; do
    # Get bucket location
    bucket_region=$(aws s3api get-bucket-location --bucket "$bucket" --query "LocationConstraint" --output text 2>/dev/null || continue)
    
    # Normalize region (null means us-east-1)
    if [[ "$bucket_region" == "null" ]] || [[ -z "$bucket_region" ]]; then
        bucket_region="us-east-1"
    fi
    
    # Check if bucket is in one of our target regions
    if echo "$REGIONS" | grep -q "$bucket_region"; then
        if [ "$first" = true ]; then
            first=false
        else
            echo -n ','
        fi
        echo -n "\"$bucket\":\"$bucket_region\""
    fi
done

echo -n '}'