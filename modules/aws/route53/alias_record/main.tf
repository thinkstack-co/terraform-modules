resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.name
  type    = var.type

  set_identifier  = var.set_identifier
  health_check_id = var.health_check_id
  alias {
    name                   = var.alias_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.alias_evaluate_target_health
  }
}
