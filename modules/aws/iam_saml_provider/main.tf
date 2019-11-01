terraform {
  required_version = ">= 0.12.0"
}

resource "aws_iam_saml_provider" "this" {
  name                   = var.name
  saml_metadata_document = var.saml_metadata_document
}
