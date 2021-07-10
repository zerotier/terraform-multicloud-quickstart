variable "allow_stopping_for_update" {
  default = null
}

variable "can_ip_forward" {
  default = null
}

variable "deletion_protection" {
  default = null
}

variable "description" {
  default = null
}

variable "desired_status" {
  default = null
}

variable "enable_display" {
  default = null
}

variable "hostname" {
  default = null
}

variable "labels" {
  default = null
}

variable "machine_type" {
  type = string
}

variable "min_cpu_platform" {
  default = null
}

variable "name" {
  default = null
}

variable "project" {
  default = null
}

variable "resource_policies" {
  default = null
}

variable "tags" {
  default = null
}

variable "zone" {
  default = null
}

variable "boot_disk_auto_delete" {
  default = null
}

variable "boot_disk_device_name" {
  default = null
}

variable "boot_disk_mode" {
  default = null
}

variable "boot_disk_encryption_key_raw" {
  default = null
}

variable "boot_disk_kms_key_self_link" {
  default = null
}

variable "boot_disk_source" {
  default = null
}

variable "initialize_params_size" {
  default = null
}

variable "initialize_params_type" {
  default = null
}

variable "initialize_params_image" {
  default = null
}

variable "network_interface_subnetwork" {
  default = null
}

variable "access_config_nat_ip" {
  default = null
}

variable "access_config_public_ptr_domain_name" {
  default = null
}

variable "access_config_network_tier" {
  default = null
}

variable "user_data" {
  default = null
  # sensitive = true
}

variable "ssh_keys" {
  default = null
}
