
module "instance" {
  source    = "./modules/instance"
  image     = var.image
  size      = var.size
  name      = var.name
  region    = var.region
  ipv6      = true
  tags      = []
  user_data = data.template_cloudinit_config.do.rendered
}

resource "tls_private_key" "do" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

data "template_cloudinit_config" "do" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "service_account.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/hostname.tpl", {
      "hostname" = var.name,
      "fqdn"     = "${var.name}.${var.dnsdomain}"
    })
  }

  part {
    filename     = "ssh.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/ssh.tpl", {
      "algorithm"   = lower(tls_private_key.do.algorithm)
      "private_key" = indent(4, chomp(tls_private_key.do.private_key_pem))
      "public_key"  = indent(4, chomp(tls_private_key.do.public_key_openssh))
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
      "zt_token"    = var.zt_token
    })
  }
}
