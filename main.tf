#
# ZeroTier Central
#

resource "zerotier_identity" "instances" {
  for_each = { for k, v in var.instances : k => (v) if v.enabled }
}

resource "zerotier_network" "demolab" {
  name        = "demo.lab"
  description = "ZeroTier Terraform Demolab"
  assign_ipv6 {
    zerotier = true
    sixplane = true
    rfc4193  = true
  }
  assignment_pool {
    start = "10.0.0.1"
    end   = "10.0.0.254"
  }
  route {
    target = "10.0.0.0/16"
  }
  # flow_rules = templatefile("${path.module}/flow_rules.tpl", {
  #   ethertap = zerotier_identity.instances["do"].id
  # })
}

resource "zerotier_member" "devices" {
  for_each    = var.devices
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = zerotier_network.demolab.id
}

resource "zerotier_member" "instances" {
  for_each           = { for k, v in var.instances : k => (v) if v.enabled }
  name               = each.key
  member_id          = zerotier_identity.instances[each.key].id
  description        = each.value.description
  network_id         = zerotier_network.demolab.id
  no_auto_assign_ips = false
  ip_assignments     = [each.value.ip_assignment]
}

resource "zerotier_token" "this" {
  name = "demolab"
}

#
# Digital Ocean
#

module "do" {
  source      = "./modules/do"
  for_each    = { for k, v in var.instances : k => v if k == "do" && v.enabled }
  name        = "do"
  image       = "ubuntu-20-04-x64"
  region      = "nyc1"
  size        = "s-1vcpu-1gb-amd"
  dnsdomain   = zerotier_network.demolab.name
  pod_cidr    = "10.42.1.1/24"
  script      = "init-demolab.tpl"
  svc         = var.users
  zeronsd     = true
  zt_identity = zerotier_identity.instances["do"]
  zt_network  = zerotier_network.demolab.id
  zt_token    = zerotier_token.this.token
}

#
# Amazon Web Services
#

module "aws" {
  source            = "./modules/aws"
  for_each          = { for k, v in var.instances : k => v if k == "aws" && v.enabled }
  name              = "aws"
  cidr_block        = "192.168.0.0/16"
  availability_zone = "us-east-1a"
  instance_type     = "t3.micro"
  dnsdomain         = zerotier_network.demolab.name
  pod_cidr          = "10.42.2.1/24"
  script            = "init-demolab.tpl"
  svc               = var.users
  zt_identity       = zerotier_identity.instances["aws"]
  zt_network        = zerotier_network.demolab.id
}

#
# Google Compute Platform
#

module "gcp" {
  source        = "./modules/gcp"
  for_each      = { for k, v in var.instances : k => v if k == "gcp" && v.enabled }
  name          = "gcp"
  ip_cidr_range = "192.168.0.0/16"
  region        = "us-east4"
  zone          = "us-east4-a"
  dnsdomain     = zerotier_network.demolab.name
  pod_cidr      = "10.42.3.1/24"
  script        = "init-demolab.tpl"
  svc           = var.users
  zt_identity   = zerotier_identity.instances["gcp"]
  zt_network    = zerotier_network.demolab.id
}

#
# Microsoft Azure
#

module "azu" {
  source              = "./modules/azu"
  for_each            = { for k, v in var.instances : k => v if k == "azu" && v.enabled }
  name                = "azu"
  address_space       = ["192.168.0.0/16", "ace:cab:deca::/48"]
  v4_address_prefixes = ["192.168.1.0/24"]
  v6_address_prefixes = ["ace:cab:deca:deed::/64"]
  location            = "eastus"
  dnsdomain           = zerotier_network.demolab.name
  pod_cidr            = "10.42.4.1/24"
  script              = "init-demolab.tpl"
  svc                 = var.users
  zt_identity         = zerotier_identity.instances["azu"]
  zt_network          = zerotier_network.demolab.id
}

#
# Oracle Cloud Infrastructure
#

variable "compartment_id" { default = "set_me_as_a_TF_VAR_" }

module "oci" {
  source         = "./modules/oci"
  for_each       = { for k, v in var.instances : k => v if k == "oci" && v.enabled }
  name           = "oci"
  vpc_cidr       = "192.168.0.0/16"
  subnet_cidr    = "192.168.1.0/24"
  compartment_id = var.compartment_id
  dnsdomain      = zerotier_network.demolab.name
  pod_cidr       = "10.42.5.1/24"
  script         = "init-demolab.tpl"
  svc            = var.users
  zt_identity    = zerotier_identity.instances["oci"]
  zt_network     = zerotier_network.demolab.id
}

#
# IBM Cloud
#

module "ibm" {
  source      = "./modules/ibm"
  for_each    = { for k, v in var.instances : k => v if k == "ibm" && v.enabled }
  name        = "ibm"
  vpc_cidr    = "192.168.0.0/16"
  subnet_cidr = "192.168.1.0/24"
  dnsdomain   = zerotier_network.demolab.name
  pod_cidr    = "10.42.6.1/24"
  script      = "init-demolab.tpl"
  svc         = var.users
  zt_identity = zerotier_identity.instances["ibm"]
  zt_network  = zerotier_network.demolab.id
}

#
# Vultr
#

module "vul" {
  source      = "./modules/vul"
  for_each    = { for k, v in var.instances : k => v if k == "vul" && v.enabled }
  name        = "vul"
  dnsdomain   = zerotier_network.demolab.name
  pod_cidr    = "10.42.7.1/24"
  script      = "init-demolab.tpl"
  svc         = var.users
  zt_identity = zerotier_identity.instances["vul"]
  zt_network  = zerotier_network.demolab.id
}

#
# Alibaba cloud
#

module "ali" {
  source      = "./modules/ali"
  for_each    = { for k, v in var.instances : k => v if k == "ali" && v.enabled }
  name        = "ali"
  dnsdomain   = zerotier_network.demolab.name
  pod_cidr    = "10.42.8.1/24"
  script      = "init-demolab.tpl"
  svc         = var.users
  zt_identity = zerotier_identity.instances["ali"]
  zt_network  = zerotier_network.demolab.id
}

#
# Equinix Metal
#

module "eqx" {
  source      = "./modules/eqx"
  for_each    = { for k, v in var.instances : k => v if k == "eqx" && v.enabled }
  name        = "eqx"
  dnsdomain   = zerotier_network.demolab.name
  pod_cidr    = "10.42.9.1/24"
  script      = "init-demolab.tpl"
  svc         = var.users
  zt_identity = zerotier_identity.instances["eqx"]
  zt_network  = zerotier_network.demolab.id
}
