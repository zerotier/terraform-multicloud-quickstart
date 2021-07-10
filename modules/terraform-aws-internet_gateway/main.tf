
resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags   = var.tags
}
