terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.36.0"
    }
  }
}

resource "azuread_named_location" "this" {
  display_name = var.display_name

  dynamic "country" {
    for_each = try(var.country, [])
    content {
      countries_and_regions                 = country.value.countries_and_regions
      include_unknown_countries_and_regions = country.value.include_unknown_countries_and_regions
    }
  }

  dynamic "ip" {
    for_each = try(var.ip, [])
    content {
      ip_ranges = ip.value.ip_ranges
      trusted   = ip.value.trusted
    }
  }
}
