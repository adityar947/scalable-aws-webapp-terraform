output "public_ips" {
  value = [
    aws_instance.instance1.public_ip
    # aws_instance.instance2.public_ip,
    # aws_instance.instance3.public_ip
  ]
}

output "private_ips" {
  value = [
    aws_instance.instance1.private_ip
    # aws_instance.instance2.private_ip,
    # aws_instance.instance3.private_ip
  ]
}

output "target_group_id" {
  value = aws_instance.instance1.id
}