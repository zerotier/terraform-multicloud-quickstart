
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
  instance_type          = var.instance_type
  source_dest_check      = false
  subnet_id              = var.subnet.id
  tags                   = { "Name" = var.name }
  user_data              = data.template_cloudinit_config.aws.rendered
  vpc_security_group_ids = [var.security_group.id]
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
