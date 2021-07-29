#
# ZeroTier Central
#

resource "zerotier_token" "this" {
  name = "quickstart"
}

resource "zerotier_identity" "instances" {
  for_each = { for i in [
    "do",
    "aws",
    "gcp",
    "azu"
  ] : i => (i) }
}

resource "zerotier_network" "quickstart" {
  name        = "demo.lab"
  description = "ZeroTier Terraform Quickstart"
  assignment_pool {
    start = "10.4.2.1/24"
    end   = "10.4.2.254/24"
  }
  assign_ipv6 {
    zerotier = true
    sixplane = true
    rfc4193  = true
  }
  route {
    target = "10.4.2.0/24"
  }
  flow_rules = templatefile("${path.module}/flow_rules.tpl", {
    ethertap = zerotier_identity.instances["aws"].id
  })
}

#
# People
#

resource "zerotier_member" "people" {
  for_each    = var.people
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = zerotier_network.quickstart.id
}

#
# Digital Ocean
#

resource "zerotier_member" "do" {
  name           = "do"
  description    = "Digital Ocean"
  member_id      = zerotier_identity.instances["do"].id
  network_id     = zerotier_network.quickstart.id
  ip_assignments = ["10.4.2.1"]
}

module "do" {
  source    = "./modules/do"
  name      = "do"
  image     = "ubuntu-20-04-x64"
  region    = "fra1"
  dnsdomain = zerotier_network.quickstart.name
  zt_networks = {
    quickstart = {
      id        = zerotier_network.quickstart.id
      dnsdomain = zerotier_network.quickstart.name
      ipv4      = resource.zerotier_member.do.ip_assignments[0]
    }
  }
  zt_identity = zerotier_identity.instances["do"]
  svc         = var.svc
  zt_token    = zerotier_token.this.token
  script      = "init-zeronsd.tpl"
}

#
# Amazon Web Services
#

resource "zerotier_member" "aws" {
  name           = "aws"
  description    = "Amazon Web Services"
  member_id      = zerotier_identity.instances["aws"].id
  network_id     = zerotier_network.quickstart.id
  ip_assignments = ["10.4.2.2"]
}

module "aws" {
  source            = "./modules/aws"
  name              = "aws"
  cidr_block        = "192.168.0.0/16"
  availability_zone = "us-east-2a"
  instance_type     = "t3.micro"
  dnsdomain     = zerotier_network.quickstart.name
  zt_networks = {
    quickstart = {
      id        = zerotier_network.quickstart.id
      dnsdomain = zerotier_network.quickstart.name
      ipv4      = resource.zerotier_member.aws.ip_assignments[0]
    }
  }
  zt_identity = zerotier_identity.instances["aws"]
  svc         = var.svc
  script      = "init-common.tpl"
}

#
# Google Compute Platform
#

resource "zerotier_member" "gcp" {
  name           = "gcp"
  description    = "Google Compute Platform"
  member_id      = zerotier_identity.instances["gcp"].id
  network_id     = zerotier_network.quickstart.id
  ip_assignments = ["10.4.2.3"]
}


module "gcp" {
  source        = "./modules/gcp"
  name          = "gcp"
  ip_cidr_range = "192.168.0.0/16"
  region        = "europe-west4"
  zone          = "europe-west4-a"
  dnsdomain     = zerotier_network.quickstart.name
  zt_networks = {
    quickstart = {
      id        = zerotier_network.quickstart.id
      dnsdomain = zerotier_network.quickstart.name
      ipv4      = resource.zerotier_member.gcp.ip_assignments[0]
    }
  }
  zt_identity = zerotier_identity.instances["gcp"]
  svc         = var.svc
  script      = "init-common.tpl"
}

#
# Microsoft Azure
#

resource "zerotier_member" "azu" {
  name           = "azu"
  description    = "Microsoft Azure"
  member_id      = zerotier_identity.instances["azu"].id
  network_id     = zerotier_network.quickstart.id
  ip_assignments = ["10.4.2.4"]
}

module "azu" {
  source              = "./modules/azu"
  name                = "azu"
  address_space       = ["192.168.0.0/16", "ace:cab:deca::/48"]
  v4_address_prefixes = ["192.168.1.0/24"]
  v6_address_prefixes = ["ace:cab:deca:deed::/64"]
  dnsdomain           = zerotier_network.quickstart.name
  zt_networks = {
    quickstart = {
      id        = zerotier_network.quickstart.id
      dnsdomain = zerotier_network.quickstart.name
      ipv4      = resource.zerotier_member.azu.ip_assignments[0]
    }
  }
  zt_identity = zerotier_identity.instances["azu"]
  svc         = var.svc
  script      = "init-common.tpl"
}
