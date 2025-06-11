variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "subnet_id_1" {
  description = "Subnet ID for the first instance"
  type        = string
}

variable "subnet_id_2" {
  description = "Subnet ID for the second and third instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile for EC2 instances"
  type        = string
}

variable "security_group_ids_server1" {
  description = "The security group ID for server 1"
  type        = list(string)
}

variable "security_group_ids_server2" {
  description = "The security group ID for server 2"
  type        = list(string)
}

variable "security_group_ids_server3" {
  description = "The security group ID for server 3"
  type        = list(string)
}

