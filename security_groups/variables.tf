variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

variable "ssh_ip" {
  description = "The IP address from which SSH will be allowed"
  type        = string
}

variable "anywhere_ipv4" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

variable "http_ip" {
  description = "The IP address from which HTTP will be allowed"
  type        = string
}

variable "https_ip" {
  description = "The IP address from which HTTPS will be allowed"
  type        = string
}

variable "custom_port_subnet" {
  description = "The subnet IP address range from which a custom port will be allowed"
  type        = string
}
