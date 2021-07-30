
resource "aws_vpc" "this" {
  cidr_block                       = var.cidr_block
  enable_dns_support               = true
  enable_dns_hostnames             = false
  assign_generated_ipv6_cidr_block = true
  tags                             = { "Name" = var.name }
}

resource "aws_subnet" "this" {
  availability_zone               = var.availability_zone
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 8, 0)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 0)
  assign_ipv6_address_on_creation = true
  vpc_id                          = aws_vpc.this.id
  tags                            = { "Name" = "${var.name}-zone-00" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { "Name" = var.name }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { "Name" = var.name }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route" "the_internet_v4" {
  route_table_id         = aws_route_table.this.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "the_internet_v6" {
  route_table_id              = aws_route_table.this.id
  gateway_id                  = aws_internet_gateway.this.id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_network_acl" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { "Name" = var.name }
}

resource "aws_network_acl_rule" "allow_all" {
  network_acl_id = aws_network_acl.this.id
  cidr_block     = "0.0.0.0/0"
  rule_number    = 100
  protocol       = "-1"
  from_port      = 0
  to_port        = 0
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "allow_all_v6" {
  network_acl_id  = aws_network_acl.this.id
  ipv6_cidr_block = "::/0"
  rule_number     = 101
  protocol        = "-1"
  from_port       = 0
  to_port         = 0
  rule_action     = "allow"
}

resource "aws_security_group" "this" {
  vpc_id      = aws_vpc.this.id
  name        = "allow_all"
  description = "allow_all"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { "Name" = "allow_all" }
}

output "subnet" {
  value = aws_subnet.this
}

output "security_group" {
  value = aws_security_group.this
}
