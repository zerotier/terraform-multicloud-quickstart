
resource "aws_subnet" "this" {
  availability_zone               = var.availability_zone
  availability_zone_id            = var.availability_zone_id
  cidr_block                      = var.cidr_block
  customer_owned_ipv4_pool        = var.customer_owned_ipv4_pool
  ipv6_cidr_block                 = var.ipv6_cidr_block
  map_customer_owned_ip_on_launch = var.map_customer_owned_ip_on_launch
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  outpost_arn                     = var.outpost_arn
  assign_ipv6_address_on_creation = var.assign_ipv6_address_on_creation
  vpc_id                          = var.vpc_id
  tags                            = var.tags
}
