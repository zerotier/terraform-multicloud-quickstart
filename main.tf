#
# ZeroTier Central
#

resource "zerotier_network" "demolab" {
  name        = "demo.lab"
  description = "ZeroTier Terraform Demolab"
  assignment_pool {
    start = "10.4.2.1"
    end   = "10.4.2.254"
  }
  route {
    target = "10.4.2.0/24"
  }
  flow_rules = templatefile("${path.module}/flow_rules.tpl", {
    ethertap = zerotier_identity.instances["do"].id
  })
}

resource "zerotier_identity" "instances" {
  for_each = { for i in [
    "do",
    "aws",
    "gcp",
    "azu"
  ] : i => (i) }
}

resource "zerotier_member" "people" {
  for_each    = var.people
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = zerotier_network.demolab.id
}

resource "zerotier_member" "do" {
  name           = "do"
  description    = "Digital Ocean"
  member_id      = zerotier_identity.instances["do"].id
  network_id     = zerotier_network.demolab.id
  ip_assignments = ["10.4.2.1"]
}

resource "zerotier_member" "aws" {
  name           = "aws"
  description    = "Amazon Web Services"
  member_id      = zerotier_identity.instances["aws"].id
  network_id     = zerotier_network.demolab.id
  ip_assignments = ["10.4.2.2"]
}

resource "zerotier_member" "gcp" {
  name           = "gcp"
  description    = "Google Compute Platform"
  member_id      = zerotier_identity.instances["gcp"].id
  network_id     = zerotier_network.demolab.id
  ip_assignments = ["10.4.2.3"]
}

resource "zerotier_member" "azu" {
  name           = "azu"
  description    = "Microsoft Azure"
  member_id      = zerotier_identity.instances["azu"].id
  network_id     = zerotier_network.demolab.id
  ip_assignments = ["10.4.2.4"]
}

#
# Digital Ocean
#

resource "zerotier_token" "this" {
  name = "demolab"
}

module "do" {
  source    = "./modules/do"
  for_each  = { for k, b in var.enabled : (k) => k if k == "do" && b }
  name      = "do"
  image     = "ubuntu-20-04-x64"
  region    = "fra1"
  dnsdomain = zerotier_network.demolab.name
  zt_networks = {
    demolab = {
      id        = zerotier_network.demolab.id
      dnsdomain = zerotier_network.demolab.name
    }
  }
  zt_identity = zerotier_identity.instances["do"]
  svc         = var.svc
  zt_token    = zerotier_token.this.token
  script      = "init-zeronsd.tpl"
  depends_on  = [zerotier_member.do]
}

#
# Amazon Web Services
#

module "aws" {
  source            = "./modules/aws"
  for_each          = { for k, b in var.enabled : (k) => k if k == "aws" && b }
  name              = "aws"
  cidr_block        = "192.168.0.0/16"
  availability_zone = "us-east-2a"
  instance_type     = "t3.micro"
  dnsdomain         = zerotier_network.demolab.name
  zt_networks       = { demolab = { id = zerotier_network.demolab.id } }
  zt_identity       = zerotier_identity.instances["aws"]
  svc               = var.svc
  script            = "init-common.tpl"
  depends_on        = [zerotier_member.aws]
}

#
# Google Compute Platform
#

module "gcp" {
  source        = "./modules/gcp"
  for_each      = { for k, b in var.enabled : (k) => k if k == "gcp" && b }
  name          = "gcp"
  ip_cidr_range = "192.168.0.0/16"
  region        = "europe-west4"
  zone          = "europe-west4-a"
  dnsdomain     = zerotier_network.demolab.name
  zt_networks   = { demolab = { id = zerotier_network.demolab.id } }
  zt_identity   = zerotier_identity.instances["gcp"]
  svc           = var.svc
  script        = "init-common.tpl"
  depends_on    = [zerotier_member.gcp]
}

#
# Microsoft Azure
#

module "azu" {
  source              = "./modules/azu"
  for_each            = { for k, b in var.enabled : (k) => k if k == "azu" && b }
  name                = "azu"
  address_space       = ["192.168.0.0/16", "ace:cab:deca::/48"]
  v4_address_prefixes = ["192.168.1.0/24"]
  v6_address_prefixes = ["ace:cab:deca:deed::/64"]
  dnsdomain           = zerotier_network.demolab.name
  zt_networks         = { demolab = { id = zerotier_network.demolab.id } }
  zt_identity         = zerotier_identity.instances["azu"]
  svc                 = var.svc
  script              = "init-common.tpl"
  depends_on          = [zerotier_member.azu]
}
