
data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "dnsdomain"   = var.dnsdomain
      "hostname"    = var.name
      "pod_cidr"    = var.pod_cidr
      "svc"         = var.svc
      "zeronsd"     = var.zeronsd
      "zt_identity" = var.zt_identity
      "zt_network"  = var.zt_network
      "zt_token"    = var.zt_token
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
  ssh_keys  = [digitalocean_ssh_key.this.id]
  user_data = data.cloudinit_config.this.rendered
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
