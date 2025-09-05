output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}
output "nat_instance_id" {
  value = aws_instance.nat.id
}

output "nat_instance_public_ip" {
  value = aws_eip.nat.public_ip
}

output "nat_instance_private_ip" {
  value = aws_instance.nat.private_ip
}

output "ansible_instance_id" {
  value = aws_instance.ansible.id
}
