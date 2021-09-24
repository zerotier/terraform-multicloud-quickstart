
data "google_project" "this" {}

resource "google_compute_network" "this" {
  name                    = var.name
  project                 = data.google_project.this.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = var.name
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

resource "google_compute_firewall" "ingress" {
  name    = "${var.name}-ingress"
  network = google_compute_network.this.self_link

  direction = "INGRESS"
  allow {
    protocol = "udp"
    ports    = ["9993"]
  }
}

resource "google_compute_firewall" "egress" {
  name    = "${var.name}-egress"
  network = google_compute_network.this.self_link

  direction = "EGRESS"
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
}

resource "google_compute_instance" "this" {
  can_ip_forward = true
  machine_type   = var.machine_type
  description    = var.name
  hostname       = "${var.name}.${var.dnsdomain}"
  name           = var.name
  project        = data.google_project.this.project_id
  zone           = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.this.id
    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  metadata = {
    user-data = data.cloudinit_config.this.rendered
  }
}

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
