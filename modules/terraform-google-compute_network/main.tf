
resource "google_compute_network" "this" {
  name                            = var.name
  description                     = var.description
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  mtu                             = var.mtu
  project                         = var.project
  delete_default_routes_on_create = var.delete_default_routes_on_create
}
