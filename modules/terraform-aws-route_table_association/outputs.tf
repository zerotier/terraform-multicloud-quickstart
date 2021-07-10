
output "subnet_id" {
  value = aws_route_table_association.this.subnet_id
}

output "gateway_id" {
  value = aws_route_table_association.this.gateway_id
}

output "route_table_id" {
  value = aws_route_table_association.this.route_table_id
}

output "id" {
  value = aws_route_table_association.this.id
}
