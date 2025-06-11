ami                  = "ami-005fc0f236362e99f"
key_name             = "My-AWS-Key"

ssh_ip                = "192.168.0.0/32"  # Allow SSH access from a specific IP
http_ip               = "0.0.0.0/0"  # Allow HTTP from any IP
https_ip              = "0.0.0.0/0"  # Allow HTTPS from any IP
custom_port_subnet    = "192.168.0.0/32"  # Allow custom port 8080 from specific subnet
anywhere_ipv4         = "0.0.0.0/0"

ssh_private_key_file = "file_name.pem"
