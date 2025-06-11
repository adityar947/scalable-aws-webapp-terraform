resource "aws_launch_template" "my_launch_template" {
  name_prefix   = var.name
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_groups
  }
}

resource "aws_autoscaling_group" "my_asg" {
  desired_capacity     = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnets
  target_group_arns   = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
}
