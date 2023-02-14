resource "aws_route53_record" "this" {
    zone_id                          = var.zone_id
    name                             = var.name
    type                             = var.type
    ttl                              = var.ttl
    records                          = var.records

    set_identifier                   = var.set_identifier
    health_check_id                  = var.health_check_id

    latency_routing_policy {
        region                       = var.latency_routing_policy_region
    }
}
