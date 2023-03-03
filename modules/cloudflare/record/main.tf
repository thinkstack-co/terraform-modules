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