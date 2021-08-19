data "vultr_region" "this" {
  filter {
    name   = "id"
    values = ["ewr"]
  }
}

data "vultr_os" "this" {
  filter {
    name   = "name"
    values = ["Ubuntu 20.04 x64"]
  }
}

data "vultr_plan" "this" {
  filter {
    name   = "id"
    values = ["vc2-1c-1gb"]
  }
}

resource "vultr_startup_script" "this" {
  name = var.name
  script = base64encode(templatefile("${path.root}/${var.script}", {
    "hostname"    = var.name
    "dnsdomain"   = var.dnsdomain
    "zt_identity" = var.zt_identity
    "zt_networks" = var.zt_networks
    "svc"         = var.svc
  }))
}


resource "vultr_firewall_group" "this" {
  description = var.name
}

resource "vultr_firewall_rule" "zt_v4" {
  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "udp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "9993"
  notes             = "zerotier"
}

resource "vultr_firewall_rule" "zt_v6" {
  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "udp"
  ip_type           = "v6"
  subnet            = "::"
  subnet_size       = 0
  port              = "9993"
  notes             = "zerotier"
}

resource "vultr_instance" "this" {
  plan              = data.vultr_plan.this.id
  region            = data.vultr_region.this.id
  os_id             = data.vultr_os.this.id
  label             = var.name
  tag               = var.name
  hostname          = var.name
  enable_ipv6       = true
  backups           = "disabled"
  ddos_protection   = false
  activation_email  = false
  firewall_group_id = vultr_firewall_group.this.id
  script_id         = vultr_startup_script.this.id
}
