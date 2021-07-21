
# locals {
#   gcp_name         = "gcp"
#   gcp_machine_type = "e2-medium"
#   gcp_region       = "europe-west4"
#   gcp_zone         = "europe-west4-a"
#   gcp_image        = "ubuntu-os-cloud/ubuntu-2004-lts"
# }

# data "google_project" "this" {}

# resource "google_compute_network" "this" {
#   name                    = local.gcp_name
#   project                 = data.google_project.this.project_id
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "this" {
#   name          = "${local.gcp_name}-zone-00"
#   network       = google_compute_network.this.self_link
#   region        = local.gcp_region
#   ip_cidr_range = "192.168.1.0/24"
# }

# resource "google_compute_address" "this" {
#   name         = local.gcp_name
#   description  = local.gcp_name
#   region       = local.gcp_region
#   project      = data.google_project.this.project_id
#   address_type = "EXTERNAL"
# }

# resource "google_compute_firewall" "this" {
#   name    = "allow-all"
#   network = google_compute_network.this.self_link

#   allow { protocol = "tcp" }
#   allow { protocol = "udp" }
#   allow { protocol = "icmp" }
# }

# resource "google_compute_instance" "this" {
#   can_ip_forward = true
#   machine_type   = local.gcp_machine_type
#   description    = local.gcp_name
#   hostname       = "${local.gcp_name}.${local.dnsdomain}"
#   name           = local.gcp_name
#   project        = data.google_project.this.project_id
#   zone           = local.gcp_zone

#   boot_disk {
#     initialize_params {
#       image = local.gcp_image
#     }
#   }

#   network_interface {
#     subnetwork = google_compute_subnetwork.this.id
#     access_config {
#       nat_ip = google_compute_address.this.address
#     }
#   }

#   metadata = {
#     user-data = data.template_cloudinit_config.gcp.rendered
#   }
# }

# resource "tls_private_key" "gcp" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# data "template_cloudinit_config" "gcp" {
#   gzip          = false
#   base64_encode = false

#   part {
#     filename     = "service_account.cfg"
#     content_type = "text/cloud-config"
#     content      = templatefile("${path.module}/tpl/users.tpl", { "svc" = var.svc })
#   }

#   part {
#     filename     = "hostname.cfg"
#     content_type = "text/cloud-config"
#     content = templatefile("${path.module}/tpl/hostname.tpl", {
#       "hostname" = local.gcp_name,
#       "fqdn"     = "${local.gcp_name}.${local.dnsdomain}"
#     })
#   }

#   part {
#     filename     = "ssh.cfg"
#     content_type = "text/cloud-config"
#     content = templatefile("${path.module}/tpl/ssh.tpl", {
#       "algorithm"   = lower(tls_private_key.gcp.algorithm)
#       "private_key" = indent(4, chomp(tls_private_key.gcp.private_key_pem))
#       "public_key"  = indent(4, chomp(tls_private_key.gcp.public_key_openssh))
#     })
#   }

#   part {
#     filename     = "zerotier.cfg"
#     content_type = "text/cloud-config"
#     content = templatefile("${path.module}/tpl/zt_identity.tpl", {
#       "public_key"  = zerotier_identity.instances["gcp"].public_key
#       "private_key" = zerotier_identity.instances["gcp"].private_key
#     })
#   }


#   part {
#     filename     = "init-common.sh"
#     content_type = "text/x-shellscript"
#     content = templatefile("${path.module}/tpl/init-common.tpl", {
#       "dnsdomain"  = local.dnsdomain
#       "zt_network" = module.demolab.id
#     })
#   }
# }
