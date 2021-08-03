variable "can_ip_forward" {
  type = bool
}

variable "machine_type" {
  type = string
}

variable "description" {
  type = string
}

variable "hostname" {
  type = string
}

variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "zone" {
  type = string
}

variable "image" {
  type = string
}

variable "network_interfaces" {
  type = list(
    object({
      subnetwork = string,
      nat_ip     = string
  }))
}

variable "user_data" {
  sensitive = true
}

resource "google_compute_instance" "this" {
  can_ip_forward = var.can_ip_forward
  machine_type   = var.machine_type
  description    = var.description
  hostname       = var.hostname
  name           = var.name
  project        = var.project
  zone           = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnetwork = network_interface.value.subnetwork
      access_config {
        nat_ip = network_interface.value.nat_ip
      }
    }
  }

  metadata = {
    user-data = var.user_data
  }
}
