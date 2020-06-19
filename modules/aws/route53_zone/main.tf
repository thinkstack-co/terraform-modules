resource "aws_route53_zone" "zone" {
  comment           = var.comment
  delegation_set_id = var.delegation_set_id
  force_detroy      = var.force_detroy
  name              = var.name
  tags              = var.tags
  vpc               = var.vpc
}
