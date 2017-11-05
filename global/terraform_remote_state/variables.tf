variable "s3_bucket_name" {
    description = "Name of the S3 bucket used to store terraform state files"
}

variable "s3_bucket_region" {
    description = "Region that the S3 bucket is located"
}

variable "dynamodb_table_name" {
    description = "DynamoDB tablet used for storing lock state"
    default     = "terraform_state_lock"
}
