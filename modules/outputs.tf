
output "network_acl_id" {
  value = aws_network_acl_rule.this.network_acl_id
}

output "rule_number" {
  value = aws_network_acl_rule.this.rule_number
}

output "egress" {
  value = aws_network_acl_rule.this.egress
}

output "protocol" {
  value = aws_network_acl_rule.this.protocol
}

output "rule_action" {
  value = aws_network_acl_rule.this.rule_action
}

output "cidr_block" {
  value = aws_network_acl_rule.this.cidr_block
}

output "ipv6_cidr_block" {
  value = aws_network_acl_rule.this.ipv6_cidr_block
}

output "from_port" {
  value = aws_network_acl_rule.this.from_port
}

output "to_port" {
  value = aws_network_acl_rule.this.to_port
}

output "icmp_type" {
  value = aws_network_acl_rule.this.icmp_type
}

output "icmp_code" {
  value = aws_network_acl_rule.this.icmp_code
}

output "id" {
  value = aws_network_acl_rule.this.id
}
