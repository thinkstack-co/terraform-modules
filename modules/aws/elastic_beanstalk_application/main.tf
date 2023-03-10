terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_elastic_beanstalk_application" "this" {
  name        = var.name
  description = var.description

  appversion_lifecycle {
    service_role          = var.service_role
    max_age_in_days       = var.max_age_in_days
    max_count             = var.max_count
    delete_source_from_s3 = var.delete_source_from_s3
  }
}
