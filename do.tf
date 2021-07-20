
locals {
  zt_token  = "kD4OJXIHvP72MZyOyI0eKIuT7xc3W59x"
  dnsdomain = module.demolab.name
}

locals {
  do_name   = "do"
  do_image  = "ubuntu-20-04-x64"
  do_region = "fra1"
  do_size   = "s-2vcpu-4gb"
}

resource "digitalocean_droplet" "this" {
  image     = local.do_image
  size      = local.do_size
  name      = local.do_name
  region    = local.do_region
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
    content      = templatefile("${path.module}/tpl/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/tpl/hostname.tpl", {
      "hostname" = local.do_name,
      "fqdn"     = "${local.do_name}.${local.dnsdomain}"
    })
  }

  part {
    filename     = "ssh.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/tpl/ssh.tpl", {
      "algorithm"   = lower(tls_private_key.do.algorithm)
      "private_key" = indent(4, chomp(tls_private_key.do.private_key_pem))
      "public_key"  = indent(4, chomp(tls_private_key.do.public_key_openssh))
    })
  }

  part {
    filename     = "zerotier.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/tpl/zt_identity.tpl", {
      "public_key"  = zerotier_identity.instances["do"].public_key
      "private_key" = zerotier_identity.instances["do"].private_key
    })
  }

  part {
    filename     = "init-zeronsd.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/tpl/init-zeronsd.tpl", {
      "dnsdomain"  = local.dnsdomain
      "zt_network" = module.demolab.id
      "zt_token"   = local.zt_token
    })
  }
}
