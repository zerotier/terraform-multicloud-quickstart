
resource "google_compute_instance" "this" {
  allow_stopping_for_update = var.allow_stopping_for_update
  can_ip_forward            = var.can_ip_forward
  deletion_protection       = var.deletion_protection
  description               = var.description
  desired_status            = var.desired_status
  enable_display            = var.enable_display
  hostname                  = var.hostname
  labels                    = var.labels
  machine_type              = var.machine_type
  min_cpu_platform          = var.min_cpu_platform
  name                      = var.name
  project                   = var.project
  resource_policies         = var.resource_policies
  tags                      = var.tags
  zone                      = var.zone

  boot_disk {
    auto_delete             = var.boot_disk_auto_delete
    device_name             = var.boot_disk_device_name
    mode                    = var.boot_disk_mode
    disk_encryption_key_raw = var.boot_disk_encryption_key_raw
    kms_key_self_link       = var.boot_disk_kms_key_self_link
    source                  = var.boot_disk_source

    initialize_params {
      size  = var.initialize_params_size
      type  = var.initialize_params_type
      image = var.initialize_params_image
    }
  }

  network_interface {
    subnetwork = var.network_interface_subnetwork

    access_config {
      nat_ip                 = var.access_config_nat_ip
      public_ptr_domain_name = var.access_config_public_ptr_domain_name
      network_tier           = var.access_config_network_tier
    }
  }

  metadata = {
    user-data = var.user_data
    ssh-keys  = var.ssh_keys
  }
}
