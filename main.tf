
resource "zerotier_identity" "instances" {
  for_each = { for i in [
    "do",
    "aws",
    "gcp",
    "azu"
  ] : i => (i) }
}

module "demolab" {
  source      = "zerotier/network/zerotier"
  version     = "0.0.17"
  name        = "demo.lab"
  description = "ZeroTier Demo Lab"
  subnets     = ["10.4.3.0/24"]
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
  source      = "zerotier/network/zerotier"
  version     = "0.0.17"
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

resource "zerotier_member" "devices" {
  for_each    = var.devices
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = module.demolab.id
}

resource "zerotier_member" "do-demolab" {
  name       = "do-demolab"
  member_id  = zerotier_identity.instances["do"].id
  network_id = module.demolab.id
}

resource "zerotier_member" "do-backplane" {
  name       = "do-backplane"
  member_id  = zerotier_identity.instances["do"].id
  network_id = module.backplane.id
}


module "do" {
  source    = "./modules/do"
  name      = "do"
  image     = "ubuntu-20-04-x64"
  region    = "fra1"
  dnsdomain = module.demolab.name
  zt_networks = {
    demolab = {
      id        = module.demolab.id
      dnsdomain = module.demolab.name
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


# resource "zerotier_member" "aws-demolab" {
#   name       = "aws-demolab"
#   member_id  = zerotier_identity.instances["aws"].id
#   network_id = module.demolab.id
# }

# resource "zerotier_member" "aws-backplane" {
#   name       = "aws-backplane"
#   member_id  = zerotier_identity.instances["aws"].id
#   network_id = module.backplane.id
# }

# resource "zerotier_member" "gcp-demolab" {
#   name       = "gcp-demolab"
#   member_id  = zerotier_identity.instances["gcp"].id
#   network_id = module.demolab.id
# }

# resource "zerotier_member" "gcp-backplane" {
#   name       = "gcp-backplane"
#   member_id  = zerotier_identity.instances["gcp"].id
#   network_id = module.backplane.id
# }

# resource "zerotier_member" "azu-demolab" {
#   name       = "azu-demolab"
#   member_id  = zerotier_identity.instances["azu"].id
#   network_id = module.demolab.id
# }

# resource "zerotier_member" "azu-backplane" {
#   name       = "azu-backplane"
#   member_id  = zerotier_identity.instances["azu"].id
#   network_id = module.backplane.id
# }

# module "aws" {
#   source            = "./modules/aws"
#   name              = "aws"
#   cidr_block        = "192.168.0.0/16"
#   availability_zone = "us-east-2a"
#   instance_type     = "t3.medium"
#   dnsdomain         = module.demolab.name
#   zt_network        = module.demolab.id
#   zt_identity       = zerotier_identity.instances["aws"]
#   svc               = var.svc
#   script            = "init-common.tpl"
# }

# module "gcp" {
#   source        = "./modules/gcp"
#   name          = "gcp"
#   ip_cidr_range = "192.168.0.0/16"
#   region        = "europe-west4"
#   zone          = "europe-west4-a"
#   dnsdomain     = module.demolab.name
#   zt_network    = module.demolab.id
#   zt_identity   = zerotier_identity.instances["gcp"]
#   svc           = var.svc
#   script        = "init-common.tpl"
# }

# module "azu" {
#   source              = "./modules/azu"
#   name                = "azu"
#   address_space       = ["192.168.0.0/16", "ace:cab:deca::/48"]
#   v4_address_prefixes = ["192.168.1.0/24"]
#   v6_address_prefixes = ["ace:cab:deca:deed::/64"]
#   dnsdomain           = module.demolab.name
#   zt_network          = module.demolab.id
#   zt_identity         = zerotier_identity.instances["azu"]
#   svc                 = var.svc
#   script              = "init-common.tpl"
# }
