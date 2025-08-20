terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

module "cloudformation_test" {
  source = "../../../modules/aws/cloudformation_test"

  stack_name = "cf-test-s3-example"

  # Optionally pass template parameters
  # parameters = {
  #   BucketName = "my-example-bucket-name"
  # }

  tags = {
    Example = "true"
  }
}
