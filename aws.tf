
resource "aws_vpc" "this" {
  cidr_block                       = "192.168.0.0/16"
  enable_dns_support               = true
  enable_dns_hostnames             = false
  assign_generated_ipv6_cidr_block = false
  tags                             = { "Name" = "aws" }
}

resource "aws_subnet" "this" {
  availability_zone               = "eu-central-1a"
  cidr_block                      = "192.168.1.0/24"
  assign_ipv6_address_on_creation = false
  vpc_id                          = aws_vpc.this.id
  tags                            = { "Name" = "aws-zone-00" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { "Name" = "aws" }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { "Name" = "aws" }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route" "the_internet" {
  route_table_id         = aws_route_table.this.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { "Name" = "aws" }
}

resource "aws_network_acl_rule" "this" {
  network_acl_id = aws_network_acl.this.id
  cidr_block     = "0.0.0.0/0"
  rule_number    = 100
  protocol       = "-1"
  from_port      = 0
  to_port        = 0
  rule_action    = "allow"
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

resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t3.micro"
  source_dest_check      = false
  subnet_id              = aws_subnet.this.id
  tags                   = { "Name" = "aws" }
  user_data              = data.template_cloudinit_config.aws.rendered
  vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_eip" "this" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.this.id
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
    filename     = "service_account.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/hostname.tpl", {
      "hostname" = "aws",
      "fqdn"     = "aws.demo.lab"
    })
  }

  part {
    filename     = "ssh.cfg"
    content_type = "text/cloud-config"
    content      = <<EOF
ssh_publish_hostkeys:
    enabled: true
no_ssh_fingerprints: false
ssh_keys:
  ${lower(tls_private_key.aws.algorithm)}_private: |
    ${indent(4, chomp(tls_private_key.aws.private_key_pem))}
  ${lower(tls_private_key.aws.algorithm)}_public: |
    ${indent(4, chomp(tls_private_key.aws.public_key_openssh))}
EOF
  }

  part {
    filename     = "zerotier.cfg"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/writefiles.tpl", {
        "files" = [
          {
            "path"    = "/var/lib/zerotier-one/identity.public",
            "mode"    = "0644",
            "content" = zerotier_identity.instances["aws"].public_key
          },
          {
            "path"    = "/var/lib/zerotier-one/identity.secret",
            "mode"    = "0600",
            "content" = zerotier_identity.instances["aws"].private_key
          }
        ]
    })
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/init-aws.tpl", {
      "dnsdomain"  = "demo.lab"
      "zt_network" = module.demolab.id
      "zt_token"   = "kD4OJXIHvP72MZyOyI0eKIuT7xc3W59x"
    })
  }
}
