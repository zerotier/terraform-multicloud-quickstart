
data "template_cloudinit_config" "do" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "hostname"    = var.name
      "dnsdomain"   = var.dnsdomain
      "zt_identity" = var.zt_identity
      "zt_networks" = var.zt_networks
      "zt_token"    = var.zt_token
      "svc"         = var.svc
    })
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "digitalocean_ssh_key" "this" {
  name       = var.name
  public_key = tls_private_key.this.public_key_openssh
}

resource "digitalocean_droplet" "this" {
  image     = var.image
  size      = var.size
  name      = var.name
  region    = var.region
  ipv6      = true
  tags      = []
  ssh_keys  = [ digitalocean_ssh_key.this.id ]
  user_data = data.template_cloudinit_config.do.rendered
}

resource "digitalocean_firewall" "this" {
  name        = var.name
  droplet_ids = [digitalocean_droplet.this.id]
  inbound_rule {
    protocol         = "udp"
    port_range       = "9993"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
