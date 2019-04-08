resource "aws_lb" "this" {
  enable_deletion_protection       = "${var.enable_deletion_protection}"
  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"
  name                             = "${var.name}"
  internal                         = "${var.internal}"
  ip_address_type                  = "${var.ip_address_type}"
  load_balancer_type               = "${var.load_balancer_type}"
  subnets                          = "${var.subnets}"
  tags                             = "${var.tags}"
  
  subnet_mapping                   = {
    subnet_id = "${var.subnet_id}"
  }
}
