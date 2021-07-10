
resource "google_compute_subnetwork" "this" {
  ip_cidr_range              = var.ip_cidr_range
  name                       = var.name
  network                    = var.network
  description                = var.description
  private_ip_google_access   = var.private_ip_google_access
  private_ipv6_google_access = var.private_ipv6_google_access
  region                     = var.region
  # dynamic "secondary_ip_range" {
  #   for_each = var.secondary_ip_range
  #   content {
  #     range_name    = secondary_ip_range.each.range_name
  #     ip_cidr_range = secondary_ip_range.each.ip_cidr_range
  #   }
  # }

  # dynamic "log_config" {
  #   for_each = var.log_config
  #   content {
  #     range_name    = log_config.each.range_name
  #     ip_cidr_range = log_config.each.ip_cidr_range
  #   }
  # }
}
