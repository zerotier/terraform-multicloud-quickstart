
output "vpc_id" {
  value = aws_network_acl.this.vpc_id
}

output "subnet_ids" {
  value = aws_network_acl.this.subnet_ids
}

output "ingress" {
  value = aws_network_acl.this.ingress
}

output "egress" {
  value = aws_network_acl.this.egress
}

output "id" {
  value = aws_network_acl.this.id
}
