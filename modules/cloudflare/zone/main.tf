terraform {
  required_version = ">= 1.0.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.0.0"
    }
  }
}

resource "cloudflare_zone" "this" {
  account_id = var.account_id
  jump_start = var.jump_start
  paused     = var.paused
  plan       = var.plan
  type       = var.type
  zone       = var.zone
}
