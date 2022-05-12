resource "azuread_named_location" "example-ip" {
  display_name = var.display_name
  ip {
    ip_ranges = var.ip_ranges
    trusted   = var.trusted
  }
  country {
    countries_and_regions                 = var.countries_and_regions
    include_unknown_countries_and_regions = var.include_unknown_countries_and_regions
  }
}
