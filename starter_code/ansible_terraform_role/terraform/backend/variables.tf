variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "dynamodb_name" {
    description = "DynamoDB table name"
    type        = string
}

variable "infrastructure_dir" {
  description = "The terraform directory where the infrastructure is defined"
  type        = string
  default = "../infrastructure"
  
}

data "aws_region" "aws_current_region" {}