#!/usr/bin/env bash
# Deletes an S3 bucket
# Usage: bash ./00_s3_cleanup.sh <bucket_name>
#   - bucket_name: the name of the bucket to delete, bucket can't have versioning enabled
# References:
#   - AWS S3 User Guide https://docs.aws.amazon.com/AmazonS3/latest/userguide/delete-bucket.html
#   - AWS CLI https://docs.aws.amazon.com/cli/latest/reference/s3/rb.html

bucket_name="${1}"
aws s3 rb "s3://${bucket_name}" --force