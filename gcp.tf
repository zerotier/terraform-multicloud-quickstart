
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
  }

  # metadata = {
  #   user-data = var.user_data
  # }
}
