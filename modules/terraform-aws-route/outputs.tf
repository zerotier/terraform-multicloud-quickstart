
output "route_table_id" {
  value = aws_route.this.route_table_id
}

output "destination_cidr_block" {
  value = aws_route.this.destination_cidr_block
}

output "destination_ipv6_cidr_block" {
  value = aws_route.this.destination_ipv6_cidr_block
}

output "egress_only_gateway_id" {
  value = aws_route.this.egress_only_gateway_id
}

output "gateway_id" {
  value = aws_route.this.gateway_id
}

output "instance_id" {
  value = aws_route.this.instance_id
}

output "nat_gateway_id" {
  value = aws_route.this.nat_gateway_id
}

output "local_gateway_id" {
  value = aws_route.this.local_gateway_id
}

output "network_interface_id" {
  value = aws_route.this.network_interface_id
}

output "transit_gateway_id" {
  value = aws_route.this.transit_gateway_id
}

output "vpc_endpoint_id" {
  value = aws_route.this.vpc_endpoint_id
}

output "vpc_peering_connection_id" {
  value = aws_route.this.vpc_peering_connection_id
}

output "id" {
  value = aws_route.this.id
}
