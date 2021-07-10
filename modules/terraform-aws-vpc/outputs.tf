
output "cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "instance_tenancy" {
  value = aws_vpc.this.instance_tenancy
}

output "enable_dns_support" {
  value = aws_vpc.this.enable_dns_support
}

output "enable_dns_hostnames" {
  value = aws_vpc.this.enable_dns_hostnames
}

output "enable_classiclink" {
  value = aws_vpc.this.enable_classiclink
}

output "enable_classiclink_dns_support" {
  value = aws_vpc.this.enable_classiclink_dns_support
}

output "assign_generated_ipv6_cidr_block" {
  value = aws_vpc.this.assign_generated_ipv6_cidr_block
}

output "tags" {
  value = aws_vpc.this.tags
}

output "id" {
  value = aws_vpc.this.id
}

output "arn" {
  value = aws_vpc.this.arn
}

output "main_route_table_id" {
  value = aws_vpc.this.main_route_table_id
}

output "default_network_acl_id" {
  value = aws_vpc.this.default_network_acl_id
}

output "default_security_group_id" {
  value = aws_vpc.this.default_security_group_id
}

output "default_route_table_id" {
  value = aws_vpc.this.default_route_table_id
}

output "ipv6_association_id" {
  value = aws_vpc.this.ipv6_association_id
}

output "ipv6_cidr_block" {
  value = aws_vpc.this.ipv6_cidr_block
}

output "owner_id" {
  value = aws_vpc.this.owner_id
}
