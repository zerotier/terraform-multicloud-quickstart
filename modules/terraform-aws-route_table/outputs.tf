
output "vpc_id" {
  value = aws_route_table.this.vpc_id
}

output "tags" {
  value = aws_route_table.this.tags
}

output "propagating_vgws" {
  value = aws_route_table.this.propagating_vgws
}

output "id" {
  value = aws_route_table.this.id
}

output "owner_id" {
  value = aws_route_table.this.owner_id
}
