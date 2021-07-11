variable "vpc_id" {}
variable "sg" {
  default = {
    allow_all = {
      "ingress" = {
        "tcp"    = { "from_port" = "0", "to_port" = "65535", "protocol" = "tcp", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
        "udp"    = { "from_port" = "0", "to_port" = "65535", "protocol" = "udp", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
        "icmp"   = { "from_port" = "8", "to_port" = "-1", "protocol" = "icmp", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
        "icmpv6" = { "from_port" = "-1", "to_port" = "-1", "protocol" = "icmpv6", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
      }
      "egress" = {
        "tcp"    = { "from_port" = "0", "to_port" = "65535", "protocol" = "tcp", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
        "udp"    = { "from_port" = "0", "to_port" = "65535", "protocol" = "udp", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
        "icmp"   = { "from_port" = "8", "to_port" = "-1", "protocol" = "icmp", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
        "icmpv6" = { "from_port" = "-1", "to_port" = "-1", "protocol" = "icmpv6", "cidr_blocks" = ["0.0.0.0/0"], "ipv6_cidr_blocks" = ["::/0"] }
      }
    }
  }
}


resource "aws_security_group" "this" {
  for_each    = var.sg
  vpc_id      = var.vpc_id
  name        = each.key
  description = each.key

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port        = lookup(ingress.value, "from_port")
      to_port          = lookup(ingress.value, "to_port")
      protocol         = lookup(ingress.value, "protocol")
      cidr_blocks      = lookup(ingress.value, "cidr_blocks")
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks")

    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port        = lookup(egress.value, "from_port")
      to_port          = lookup(egress.value, "to_port")
      protocol         = lookup(egress.value, "protocol")
      cidr_blocks      = lookup(egress.value, "cidr_blocks")
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks")
    }
  }

  tags = { "Name" = each.key }
}
