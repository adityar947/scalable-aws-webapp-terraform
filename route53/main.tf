resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "alb_record" {
  zone_id = aws_route53_zone.main.id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}