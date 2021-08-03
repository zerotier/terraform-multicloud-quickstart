
data "google_project" "this" {}

resource "google_compute_network" "this" {
  name                    = var.name
  project                 = data.google_project.this.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.name}-zone-00"
  network       = google_compute_network.this.self_link
  region        = var.region
  ip_cidr_range = var.ip_cidr_range
}

resource "google_compute_address" "this" {
  name         = var.name
  description  = var.name
  region       = var.region
  project      = data.google_project.this.project_id
  address_type = "EXTERNAL"
}

resource "google_compute_firewall" "this" {
  name    = "allow-all"
  network = google_compute_network.this.self_link

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
}

module "instance" {
  source         = "./modules/instance"
  can_ip_forward = true
  machine_type   = var.machine_type
  description    = var.name
  hostname       = "${var.name}.${var.dnsdomain}"
  name           = var.name
  project        = data.google_project.this.project_id
  zone           = var.zone
  image          = var.image
  network_interfaces = [{
    subnetwork = google_compute_subnetwork.this.id
    nat_ip     = google_compute_address.this.address
  }]
  user_data = data.template_cloudinit_config.gcp.rendered
}

resource "tls_private_key" "gcp" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

data "template_cloudinit_config" "gcp" {
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
      "algorithm"   = lower(tls_private_key.gcp.algorithm)
      "private_key" = indent(4, chomp(tls_private_key.gcp.private_key_pem))
      "public_key"  = indent(4, chomp(tls_private_key.gcp.public_key_openssh))
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
