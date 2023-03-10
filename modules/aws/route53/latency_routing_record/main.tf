terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.name
  type    = var.type
  ttl     = var.ttl
  records = var.records

  set_identifier  = var.set_identifier
  health_check_id = var.health_check_id

  latency_routing_policy {
    region = var.latency_routing_policy_region
  }
}
