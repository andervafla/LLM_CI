output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "monitoring_public_ip" {
  value = aws_instance.monitoring_instance.public_ip
}