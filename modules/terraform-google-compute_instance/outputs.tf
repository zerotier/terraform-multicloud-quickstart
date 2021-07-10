
output "self_link" {
  value = google_compute_instance.this.self_link
}

output "id" {
  value = google_compute_instance.this.id
}

output "instance_id" {
  value = google_compute_instance.this.instance_id
}

output "name" {
  value = google_compute_instance.this.name
}

output "metadata_fingerprint" {
  value = google_compute_instance.this.metadata_fingerprint
}

output "network_interface" {
  value = google_compute_instance.this.network_interface
}

output "project" {
  value = google_compute_instance.this.project
}

output "tags" {
  value = google_compute_instance.this.tags
}

output "zone" {
  value = google_compute_instance.this.zone
}

output "machine_type" {
  value = google_compute_instance.this.machine_type
}

output "hostname" {
  value = google_compute_instance.this.hostname
}

output "can_ip_forward" {
  value = google_compute_instance.this.can_ip_forward
}

output "boot_disk" {
  value = google_compute_instance.this.boot_disk
}
