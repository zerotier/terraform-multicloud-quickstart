
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


data "aws_ami" "this" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "instance" {
  source                 = "./modules/instance"
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  source_dest_check      = false
  subnet_id              = aws_subnet.this.id
  tags                   = { "Name" = var.name }
  user_data              = data.template_cloudinit_config.aws.rendered
  vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_eip" "this" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.instance.id
  allocation_id = aws_eip.this.id
}

resource "tls_private_key" "aws" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

data "template_cloudinit_config" "aws" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/hostname.tpl", {
      "hostname" = var.name
      "fqdn"     = "${var.name}.${var.dnsdomain}"
    })
  }

  part {
    filename     = "service_account.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "ssh.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/ssh.tpl", {
      "algorithm"   = lower(tls_private_key.aws.algorithm)
      "private_key" = indent(4, chomp(tls_private_key.aws.private_key_pem))
      "public_key"  = indent(4, chomp(tls_private_key.aws.public_key_openssh))
    })
  }

  part {
    filename     = "zerotier.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/zt_identity.tpl", {
      "public_key"  = var.zt_identity.public_key
      "private_key" = var.zt_identity.private_key
    })
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "dnsdomain"   = var.dnsdomain
      "zt_networks" = var.zt_networks
    })
  }
}
