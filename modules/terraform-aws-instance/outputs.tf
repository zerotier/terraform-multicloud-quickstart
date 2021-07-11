output "id" {
  value = aws_instance.this.id
}

output "subnet_id" {
  value = aws_instance.this.subnet_id
}

output "tags" {
  value = aws_instance.this.tags
}

output "ipv6_addresses" {
  value = aws_instance.this.ipv6_addresses
}

output "ipv6_address_count" {
  value = aws_instance.this.ipv6_address_count
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "secondary_private_ips" {
  value = aws_instance.this.secondary_private_ips
}

output "security_groups" {
  value = aws_instance.this.security_groups
}

output "source_dest_check" {
  value = aws_instance.this.source_dest_check
}

output "primary_network_interface_id" {
  value = aws_instance.this.primary_network_interface_id
}
