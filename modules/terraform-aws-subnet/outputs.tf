
output "id" {
  value = aws_subnet.this.id
}

output "ipv6_cidr_block_association_id" {
  value = aws_subnet.this.ipv6_cidr_block_association_id
}

output "owner_id" {
  value = aws_subnet.this.owner_id
}

output "availability_zone" {
  value = aws_subnet.this.availability_zone
}

output "availability_zone_id" {
  value = aws_subnet.this.availability_zone_id
}

output "cidr_block" {
  value = aws_subnet.this.cidr_block
}

output "customer_owned_ipv4_pool" {
  value = aws_subnet.this.customer_owned_ipv4_pool
}

output "ipv6_cidr_block" {
  value = aws_subnet.this.ipv6_cidr_block
}

output "map_customer_owned_ip_on_launch" {
  value = aws_subnet.this.map_customer_owned_ip_on_launch
}

output "map_public_ip_on_launch" {
  value = aws_subnet.this.map_public_ip_on_launch
}

output "outpost_arn" {
  value = aws_subnet.this.outpost_arn
}

output "assign_ipv6_address_on_creation" {
  value = aws_subnet.this.assign_ipv6_address_on_creation
}

output "vpc_id" {
  value = aws_subnet.this.vpc_id
}

output "tags" {
  value = aws_subnet.this.tags
}
