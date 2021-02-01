terraform {
  required_version = ">= 0.12.0"
}
resource "aws_dx_connection" "dx" {
    count     = var.count
    name      = var.name
    bandwitdh = var.bandwidth
    location  = var.location
    tags      = var.tags
}