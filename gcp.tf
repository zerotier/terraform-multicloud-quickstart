
data "google_project" "this" {}

resource "google_compute_network" "this" {
  name                    = "qs-gcp-ams"
  project                 = data.google_project.this.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "qs-gcp-ams-zone-00"
  network       = google_compute_network.this.self_link
  ip_cidr_range = "192.168.1.0/24"
  region        = "europe-west4"
}

resource "google_compute_address" "this" {
  name         = "qs-gcp-ams"
  address_type = "EXTERNAL"
  description  = "qs-gcp-ams"
  region       = "europe-west4"
  project      = data.google_project.this.project_id
}

resource "google_compute_firewall" "this" {
  name    = "allow-all"
  network = google_compute_network.this.self_link

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
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
    content      = templatefile("${path.module}/tpl/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/tpl/hostname.tpl", {
      "hostname" = "gcp",
      "fqdn"     = "gcp.demo.lab"
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
  ${lower(tls_private_key.gcp.algorithm)}_private: |
    ${indent(4, chomp(tls_private_key.gcp.private_key_pem))}
  ${lower(tls_private_key.gcp.algorithm)}_public: |
    ${indent(4, chomp(tls_private_key.gcp.public_key_openssh))}
EOF
  }

  part {
    filename     = "zerotier.cfg"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/tpl/writefiles.tpl", {
        "files" = [
          {
            "path"    = "/var/lib/zerotier-one/identity.public",
            "mode"    = "0644",
            "content" = zerotier_identity.instances["gcp"].public_key
          },
          {
            "path"    = "/var/lib/zerotier-one/identity.secret",
            "mode"    = "0600",
            "content" = zerotier_identity.instances["gcp"].private_key
          }
        ]
    })
  }

  part {
    filename     = "init-common.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/tpl/init-common.tpl", {
      "dnsdomain"  = "demo.lab"
      "zt_network" = module.demolab.id
    })
  }
}
