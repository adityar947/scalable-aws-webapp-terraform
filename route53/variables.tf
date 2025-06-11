variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "record_name" {
  description = "The name of the DNS record to create"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "The hosted zone ID of the ALB"
  type        = string
}
