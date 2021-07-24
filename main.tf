
#
# ZeroTier Central
#

resource "zerotier_identity" "instances" {
  for_each = { for i in [
    "do",
    "aws",
    "gcp",
    "azu"
  ] : i => (i) }
}

module "frontplane" {
  source      = "./modules/network"
  name        = "demo.lab"
  description = "ZeroTier Demo Lab"
  subnets     = ["10.4.2.0/24"]
  assign_ipv6 = {
    zerotier = true
    sixplane = true
    rfc4193  = true
  }
  flow_rules = templatefile("${path.module}/flow_rules.tpl", {
    ethertap = zerotier_identity.instances["do"].id
  })
}

module "backplane" {
  source      = "./modules/network"
  name        = "demo.lan"
  description = "ZeroTier Demo Backplane"
  subnets     = ["10.4.3.0/24"]
  assign_ipv6 = {
    zerotier = true
    sixplane = true
    rfc4193  = true
  }
  flow_rules = templatefile("${path.module}/flow_rules.tpl", {
    ethertap = zerotier_identity.instances["aws"].id
  })
}

#
# People
#

resource "zerotier_member" "people-frontplane" {
  for_each    = var.people
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = module.frontplane.id
}

resource "zerotier_member" "people-backplane" {
  for_each    = var.people
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = module.backplane.id
}

#
# Digital Ocean
#

resource "zerotier_member" "do-frontplane" {
  name           = "do"
  description    = "Digital Ocean"
  member_id      = zerotier_identity.instances["do"].id
  network_id     = module.frontplane.id
  ip_assignments = ["10.4.2.1"]
}

resource "zerotier_member" "do-backplane" {
  name           = "do"
  description    = "Digital Ocean"
  member_id      = zerotier_identity.instances["do"].id
  network_id     = module.backplane.id
  ip_assignments = ["10.4.3.1"]
}

module "do" {
  source    = "./modules/do"
  name      = "do"
  image     = "ubuntu-20-04-x64"
  region    = "fra1"
  dnsdomain = module.frontplane.name
  zt_networks = {
    frontplane = {
      id        = module.frontplane.id
      dnsdomain = module.frontplane.name
    }
    backplane = {
      id        = module.backplane.id
      dnsdomain = module.backplane.name
    }
  }
  zt_identity = zerotier_identity.instances["do"]
  svc         = var.svc
  zt_token    = var.zt_token
  script      = "init-zeronsd.tpl"
}

#
# Amazon Web Services
#

resource "zerotier_member" "aws-frontplane" {
  name           = "aws"
  description    = "Amazon Web Services"
  member_id      = zerotier_identity.instances["aws"].id
  network_id     = module.frontplane.id
  ip_assignments = ["10.4.2.2"]
}

resource "zerotier_member" "aws-backplane" {
  name           = "aws"
  description    = "Amazon Web Services"
  member_id      = zerotier_identity.instances["aws"].id
  network_id     = module.backplane.id
  ip_assignments = ["10.4.3.2"]
}

module "aws" {
  source            = "./modules/aws"
  name              = "aws"
  cidr_block        = "192.168.0.0/16"
  availability_zone = "us-east-2a"
  instance_type     = "t3.micro"
  # instance_type     = "t3.medium"
  dnsdomain = module.frontplane.name
  zt_networks = {
    frontplane = {
      id        = module.frontplane.id
      dnsdomain = module.frontplane.name
    }
    backplane = {
      id        = module.backplane.id
      dnsdomain = module.backplane.name
    }
  }
  zt_identity = zerotier_identity.instances["aws"]
  svc         = var.svc
  script      = "init-common.tpl"
}

#
# Google Compute Platform
#

resource "zerotier_member" "gcp-frontplane" {
  name           = "gcp"
  description    = "Google Compute Platform"
  member_id      = zerotier_identity.instances["gcp"].id
  network_id     = module.frontplane.id
  ip_assignments = ["10.4.2.3"]
}

resource "zerotier_member" "gcp-backplane" {
  name           = "gcp"
  description    = "Google Compute Platform"
  member_id      = zerotier_identity.instances["gcp"].id
  network_id     = module.backplane.id
  ip_assignments = ["10.4.3.3"]
}

# module "gcp" {
#   source        = "./modules/gcp"
#   name          = "gcp"
#   ip_cidr_range = "192.168.0.0/16"
#   region        = "europe-west4"
#   zone          = "europe-west4-a"
#   dnsdomain     = module.frontplane.name
#   zt_networks = {
#     frontplane = {
#       id        = module.frontplane.id
#       dnsdomain = module.frontplane.name
#     }
#     backplane = {
#       id        = module.backplane.id
#       dnsdomain = module.backplane.name
#     }
#   }
#   zt_identity = zerotier_identity.instances["gcp"]
#   svc         = var.svc
#   script      = "init-common.tpl"
# }

#
# Microsoft Azure
#

resource "zerotier_member" "azu-frontplane" {
  name           = "azu"
  description    = "Microsoft Azure"
  member_id      = zerotier_identity.instances["azu"].id
  network_id     = module.frontplane.id
  ip_assignments = ["10.4.2.4"]
}

resource "zerotier_member" "azu-backplane" {
  name           = "azu"
  description    = "Microsoft Azure"
  member_id      = zerotier_identity.instances["azu"].id
  network_id     = module.backplane.id
  ip_assignments = ["10.4.3.4"]
}

# module "azu" {
#   source              = "./modules/azu"
#   name                = "azu"
#   address_space       = ["192.168.0.0/16", "ace:cab:deca::/48"]
#   v4_address_prefixes = ["192.168.1.0/24"]
#   v6_address_prefixes = ["ace:cab:deca:deed::/64"]
#   dnsdomain           = module.frontplane.name
#   zt_networks = {
#     frontplane = {
#       id        = module.frontplane.id
#       dnsdomain = module.frontplane.name
#     }
#     backplane = {
#       id        = module.backplane.id
#       dnsdomain = module.backplane.name
#     }
#   }
#   zt_identity = zerotier_identity.instances["azu"]
#   svc         = var.svc
#   script      = "init-common.tpl"
# }
