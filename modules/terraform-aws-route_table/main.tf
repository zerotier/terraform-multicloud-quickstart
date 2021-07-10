
resource "aws_route_table" "this" {
  vpc_id           = var.vpc_id
  propagating_vgws = var.propagating_vgws
  tags             = var.tags
}
