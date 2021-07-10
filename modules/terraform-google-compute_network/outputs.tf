
output "name" {
  value = google_compute_network.this.name
}

output "description" {
  value = google_compute_network.this.description
}

output "auto_create_subnetworks" {
  value = google_compute_network.this.auto_create_subnetworks
}

output "routing_mode" {
  value = google_compute_network.this.routing_mode
}

output "mtu" {
  value = google_compute_network.this.mtu
}

output "project" {
  value = google_compute_network.this.project
}

output "delete_default_routes_on_create" {
  value = google_compute_network.this.delete_default_routes_on_create
}

output "id" {
  value = google_compute_network.this.id
}

output "gateway_ipv4" {
  value = google_compute_network.this.gateway_ipv4
}

output "self_link" {
  value = google_compute_network.this.self_link
}
