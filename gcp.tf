
data "google_project" "this" {}

module "google_compute_network" {
  source                  = "./modules/terraform-google-compute_network"
  name                    = "qs-gcp-ams"
  project                 = data.google_project.this.project_id
  auto_create_subnetworks = false
}

module "google_compute_subnetwork" {
  source        = "./modules/terraform-google-compute_subnetwork"
  name          = "qs-gcp-ams"
  network       = module.google_compute_network.self_link
  ip_cidr_range = "10.2.0.0/16"
  region        = "europe-west4"
}

resource "google_compute_instance" "this" {
  can_ip_forward            = true
  description               = "qs-gcp-ams"
  # hostname                  = "qs-gcp-ams"
  machine_type              = "e2-medium"
  name                      = "qs-gcp-ams"
  project                   = data.google_project.this.project_id
  zone                      = "europe-west4-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = module.google_compute_subnetwork.id
  }

  # metadata = {
  #   user-data = var.user_data
  # }
}
