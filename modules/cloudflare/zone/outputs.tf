output "id" {
  value = cloudflare_zone.this.id
}

output "name_servers" {
  value = cloudflare_zone.this.name_servers
}

output "status" {
  value = cloudflare_zone.this.status
}

output "vanity_name_servers" {
  value = cloudflare_zone.this.vanity_name_servers
}

output "verification_key" {
  value = cloudflare_zone.this.verification_key
}
