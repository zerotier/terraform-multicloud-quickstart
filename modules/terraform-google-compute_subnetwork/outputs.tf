
output "ip_cidr_range" {
  value = google_compute_subnetwork.this.ip_cidr_range
}

output "name" {
  value = google_compute_subnetwork.this.name
}

output "network" {
  value = google_compute_subnetwork.this.network
}

output "description" {
  value = google_compute_subnetwork.this.description
}

# output "secondary_ip_range" {
#   value = google_compute_subnetwork.this.secondary_ip_range
# }

output "private_ip_google_access" {
  value = google_compute_subnetwork.this.private_ip_google_access
}

output "private_ipv6_google_access" {
  value = google_compute_subnetwork.this.private_ipv6_google_access
}

output "region" {
  value = google_compute_subnetwork.this.region
}

# output "log_config" {
#   value = google_compute_subnetwork.this.log_config
# }

output "id" {
  value = google_compute_subnetwork.this.id
}

output "creation_timestamp" {
  value = google_compute_subnetwork.this.creation_timestamp
}

output "gateway_address" {
  value = google_compute_subnetwork.this.gateway_address
}

output "self_link" {
  value = google_compute_subnetwork.this.self_link
}
