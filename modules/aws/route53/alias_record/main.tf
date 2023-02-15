resource "aws_route53_record" "this" {
    zone_id                          = var.zone_id
    name                             = var.name
    type                             = var.type

    set_identifier                   = var.set_identifier
    health_check_id                  = var.health_check_id
    alias {
        name                         = var.alias_name
        zone_id                      = var.alias_zone_id
        evaluate_target_health       = var.alias_evaluate_target_health
    }
    weighted_routing_policy {
        weight                       = var.weighted_routing_policy_weight
    }
    latency_routing_policy {
        region                       = var.latency_routing_policy_region
    }
    geolocation_routing_policy {
        continent                    = var.geolocation_routing_policy_continent
        country                      = var.geolocation_routing_policy_country
        subdivision                  = var.geolocation_routing_policy_subdivision
    }
    failover_routing_policy {
        type                         = var.failover_routing_policy_type
    }
}
