variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for public subnets"
}


variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}