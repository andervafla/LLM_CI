output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

# output "private_instance_id" {
#   value = aws_instance.private_instance.id
# }