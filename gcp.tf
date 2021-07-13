
data "google_project" "this" {}

resource "google_compute_network" "this" {
  name                    = "qs-gcp-ams"
  project                 = data.google_project.this.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "qs-gcp-ams-zone-00"
  network       = google_compute_network.this.self_link
  ip_cidr_range = "10.3.0.0/16"
  region        = "europe-west4"
}

resource "google_compute_address" "this" {
  name         = "qs-gcp-ams"
  address_type = "EXTERNAL"
  description  = "qs-gcp-ams"
  region       = "europe-west4"
  project      = data.google_project.this.project_id
}

resource "google_compute_instance" "this" {
  can_ip_forward = true
  description    = "qs-gcp-ams"
  hostname       = "qs-gcp-ams.demo.lab"
  machine_type   = "e2-medium"
  name           = "qs-gcp-ams"
  project        = data.google_project.this.project_id
  zone           = "europe-west4-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.this.id
    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  metadata = {
    user-data = data.template_cloudinit_config.gcp.rendered
  }
}

resource "google_compute_firewall" "this" {
  name    = "allow-all"
  network = google_compute_network.this.self_link

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
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
    content      = <<EOF
hostname: qs-gcp-ams
fqdn: qs-gcp-ams.demo.lab
manage_etc_hosts: true
EOF
  }
}
