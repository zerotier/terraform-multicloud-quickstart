
data "metal_operating_system" "this" {
  name             = var.operating_system
  provisionable_on = var.plan
}

data "metal_metro" "sv" {
  code = "dc"
}

resource "metal_project" "this" {
  name = var.project
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "metal_project_ssh_key" "this" {
  name       = var.name
  public_key = tls_private_key.this.public_key_openssh
  project_id = metal_project.this.id
}

resource "metal_device" "this" {
  hostname            = var.name
  plan                = var.plan
  metro               = var.metro
  operating_system    = data.metal_operating_system.this.slug
  billing_cycle       = var.billing_cycle
  project_id          = metal_project.this.id
  project_ssh_key_ids = [metal_project_ssh_key.this.id]
  user_data           = data.template_cloudinit_config.this.rendered
}

data "template_cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "hostname"    = var.name
      "dnsdomain"   = var.dnsdomain
      "zt_identity" = var.zt_identity
      "zt_networks" = var.zt_networks
      "svc"         = var.svc
    })
  }
}
