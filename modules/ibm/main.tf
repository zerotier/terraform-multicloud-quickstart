
data "ibm_resource_group" "this" {
  name = "Default"
}

data "ibm_is_image" "this" {
  name = var.image
}

data "ibm_is_instance_profiles" "this" {}

resource "ibm_is_vpc" "this" {
  name                      = var.name
  resource_group            = data.ibm_resource_group.this.id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "this" {
  name = var.name
  zone = var.zone
  vpc  = ibm_is_vpc.this.id
  cidr = var.vpc_cidr
}

resource "ibm_is_public_gateway" "this" {
  name = var.name
  vpc  = ibm_is_vpc.this.id
  zone = var.zone
}

resource "ibm_is_subnet" "this" {
  name            = var.name
  vpc             = ibm_is_vpc.this.id
  zone            = var.zone
  ipv4_cidr_block = var.subnet_cidr
  public_gateway  = ibm_is_public_gateway.this.id
  depends_on      = [ibm_is_vpc_address_prefix.this]
}

resource "ibm_is_security_group" "this" {
  name           = var.name
  vpc            = ibm_is_vpc.this.id
  resource_group = data.ibm_resource_group.this.id
}

resource "ibm_is_security_group_rule" "inbound_udp" {
  group     = ibm_is_security_group.this.id
  remote    = "0.0.0.0/0"
  direction = "inbound"
  udp {
    port_min = 9993
    port_max = 9993
  }
}

# resource "ibm_is_security_group_rule" "inbound_tcp" {
#   group     = ibm_is_security_group.this.id
#   remote    = "0.0.0.0/0"
#   direction = "inbound"
#   tcp {
#     port_min = 1
#     port_max = 65535
#   }
# }

resource "ibm_is_security_group_rule" "outbound_udp" {
  group     = ibm_is_security_group.this.id
  remote    = "0.0.0.0/0"
  direction = "outbound"
  udp {
    port_min = 1
    port_max = 65535
  }
}

resource "ibm_is_security_group_rule" "outbound_tcp" {
  group     = ibm_is_security_group.this.id
  remote    = "0.0.0.0/0"
  direction = "outbound"
  tcp {
    port_min = 1
    port_max = 65535
  }
}

resource "ibm_is_instance" "this" {
  name    = var.name
  image   = data.ibm_is_image.this.id
  profile = var.instance_profile

  primary_network_interface {
    subnet            = ibm_is_subnet.this.id
    security_groups   = [ibm_is_security_group.this.id]
    allow_ip_spoofing = false
  }

  vpc            = ibm_is_vpc.this.id
  zone           = var.zone
  keys           = []
  resource_group = data.ibm_resource_group.this.id
  user_data      = data.template_cloudinit_config.ibm.rendered
}

data "template_cloudinit_config" "ibm" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.root}/hostname.tpl", {
      "hostname" = var.name
      "fqdn"     = "${var.name}.${var.dnsdomain}"
    })
  }

  part {
    filename     = "service_account.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.root}/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "zerotier.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.root}/zt_identity.tpl", {
      "public_key"  = var.zt_identity.public_key
      "private_key" = var.zt_identity.private_key
    })
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "dnsdomain"   = var.dnsdomain
      "zt_networks" = var.zt_networks
    })
  }
}
