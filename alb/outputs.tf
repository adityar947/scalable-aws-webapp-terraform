output "alb_dns_name" {
  value = aws_lb.my-alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.my-alb.zone_id
}