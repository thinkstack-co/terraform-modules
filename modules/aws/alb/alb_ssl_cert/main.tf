terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names
  key_algorithm             = var.key_algorithm
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_certificate" "cert_attach" {
  listener_arn    = var.listener_arn
  certificate_arn = var.certificate_arn
}
