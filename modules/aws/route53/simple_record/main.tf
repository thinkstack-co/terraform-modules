resource "aws_route53_record" "this" {
    zone_id                          = var.zone_id
    name                             = var.name
    type                             = var.type
    ttl                              = var.ttl
    records                          = var.records

    health_check_id                  = var.health_check_id
}
