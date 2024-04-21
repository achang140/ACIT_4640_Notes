#!/usr/bin/env bash
# Creates an S3 bucket in the specified region
# Usage: bash ./00_s3_setup.sh <bucket_name>
#   - bucket_name: the name of the bucket to create
#       - the name must be globally unique
#       - the name must be a valid DNS name
# References:
#   - AWS CLI https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html
#   - S3 User Guide https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html

declare -r region="us-west-2"

# Check if the number of command-line arguments is correct
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket_name>"
    exit 1
fi

# pass the bucket name as a positional parameter
bucket_name="$1"

# Check if the bucket exists
if aws s3api head-bucket --bucket "${bucket_name}" 2>/dev/null; then
    echo "Bucket ${bucket_name} already exists."
else
  # change the line below	
  aws s3api create-bucket \
    --bucket "${bucket_name}" \
    --region "${region}" \
    --create-bucket-configuration LocationConstraint="${region}"
fi
