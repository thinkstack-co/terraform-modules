resource "aws_lb" "network" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  subnets                    = var.subnets
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.tags
}
