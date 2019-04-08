resource "aws_lb" "this" {
  enable_deletion_protection = "${var.enable_deletion_protection}"
  enable_http2               = "${var.enable_http2}"
  name                       = "${var.name}"
  idle_timeout               = "${var.idle_timeout}"
  internal                   = "${var.internal}"
  ip_address_type            = "${var.ip_address_type}"
  load_balancer_type         = "${var.load_balancer_type}"
  security_groups            = "${var.security_groups}"
  subnets                    = "${var.subnets}"
  tags                       = "${var.tags}"

  access_logs {
    bucket  = "${var.access_logs_bucket}"
    enabled = "${var.access_logs_enabled}"
    prefix  = "${var.access_logs_prefix}"
  }

  subnet_mapping = {
    subnet_id = "${var.subnet_id}"
  }
}
