terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.42.0"
    }
  }
}

resource "tfe_oauth_client" "this" {
  name             = var.name
  organization     = var.organization
  api_url          = var.api_url
  http_url         = var.http_url
  oauth_token      = var.oauth_token
  service_provider = var.service_provider
}
