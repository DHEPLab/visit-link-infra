data "aws_acm_certificate" "certificate" {
  domain   = local.domain_name
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "hosted_zone" {
  name = local.domain_name
}

resource "aws_route53_record" "sub_app_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  name    = "${local.subdomain}.${local.domain_name}"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}