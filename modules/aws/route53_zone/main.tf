resource "aws_route53_zone" "zone" {
  comment           = var.comment
  delegation_set_id = var.delegation_set_id
  name              = var.name
  tags              = var.tags
}
