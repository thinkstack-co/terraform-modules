terraform {
  required_version = ">= 1.0.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.0.0"
    }
  }
}

resource "cloudflare_record" "this" {
  allow_overwrite = var.allow_overwrite
  comment         = var.comment
  name            = var.name
  priority        = var.priority
  proxied         = var.proxied
  tags            = var.tags
  ttl             = var.ttl
  type            = var.type
  value           = var.value
  zone_id         = var.zone_id
}