resource "aws_lb" "network" {
  enable_deletion_protection = var.enable_deletion_protection
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  name                       = var.name
  tags                       = var.tags

  subnet_mapping {
    subnet_id     = var.subnet_1_id
    allocation_id = var.allocation_1_id
  }

  subnet_mapping {
    subnet_id     = var.subnet_2_id
    allocation_id = var.allocation_2_id
  }

  subnet_mapping {
    subnet_id     = var.subnet_3_id
    allocation_id = var.allocation_3_id
  }
}
