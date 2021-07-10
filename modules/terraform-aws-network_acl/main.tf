
resource "aws_network_acl" "this" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  ingress    = var.ingress
  egress     = var.egress
  tags       = var.tags
}
