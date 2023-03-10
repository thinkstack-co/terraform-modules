terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_iam_saml_provider" "this" {
  name                   = var.name
  saml_metadata_document = var.saml_metadata_document
}
