resource "aws_instance" "instance1" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  iam_instance_profile   = var.iam_instance_profile_name
  vpc_security_group_ids = var.security_group_ids_server1
  key_name               = var.key_name
  subnet_id              = var.subnet_id_1

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install ruby-full wget -y
              cd /home/ubuntu
              wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
              chmod +x ./install
              sudo ./install auto
              sudo service codedeploy-agent start
              EOF

  tags = {
    Name = "Server-1"
  }
}

# resource "aws_instance" "instance2" {
#   ami                    = var.ami
#   instance_type          = "t3.micro"
#   iam_instance_profile   = var.iam_instance_profile_name
#   vpc_security_group_ids = var.security_group_ids_server2
#   key_name               = var.key_name
#   subnet_id              = var.subnet_id_2

#   tags = {
#     Name = "Server-2"
#   }
# }

# resource "aws_instance" "instance3" {
#   ami                    = var.ami
#   instance_type          = "t3.small"
#   iam_instance_profile   = var.iam_instance_profile_name
#   vpc_security_group_ids = var.security_group_ids_server3
#   key_name               = var.key_name
#   subnet_id              = var.subnet_id_2

#   tags = {
#     Name = "Server-3"
#   }
# }
