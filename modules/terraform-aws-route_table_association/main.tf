
resource "aws_route_table_association" "this" {
  subnet_id      = var.subnet_id
  gateway_id     = var.gateway_id
  route_table_id = var.route_table_id
}
