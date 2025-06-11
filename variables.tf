variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "anywhere_ipv4" {
  description = "CIDR block for allowing access from anywhere (e.g., 0.0.0.0/0)"
  type        = string
}

variable "custom_port_subnet" {
  description = "The subnet IP address range allowed to access a custom port"
  type        = string
}

variable "github_token_secret_name" {
  description = "The name of the GitHub token stored in AWS Secrets Manager"
  type        = string
  default     = "github-token"
}

variable "http_ip" {
  description = "CIDR block allowed to access HTTP (port 80)"
  type        = string
}

variable "https_ip" {
  description = "CIDR block allowed to access HTTPS (port 443)"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "ssh_ip" {
  description = "CIDR block allowed to access SSH (port 22)"
  type        = string
}

variable "ssh_private_key_file" {
  description = "Path to the private SSH key file used for connecting to EC2 instances"
  type        = string
}