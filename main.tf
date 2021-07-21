
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

resource "zerotier_member" "devices" {
  for_each    = var.devices
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = module.demolab.id
}

resource "zerotier_member" "do" {
  name       = "do"
  member_id  = zerotier_identity.instances["do"].id
  network_id = module.demolab.id
  # ip_assignments = ["10.4.2.1"]
}

resource "zerotier_member" "aws" {
  name           = "aws"
  member_id      = zerotier_identity.instances["aws"].id
  network_id     = module.demolab.id
  ip_assignments = ["10.4.2.2"]
}

resource "zerotier_member" "gcp" {
  name           = "gcp"
  member_id      = zerotier_identity.instances["gcp"].id
  network_id     = module.demolab.id
  ip_assignments = ["10.4.2.3"]
}

resource "zerotier_member" "azu" {
  name           = "azu"
  member_id      = zerotier_identity.instances["azu"].id
  network_id     = module.demolab.id
  ip_assignments = ["10.4.2.4"]
}

module "do" {
  source      = "./modules/do"
  name        = "do"
  image       = "ubuntu-20-04-x64"
  region      = "fra1"
  size        = "s-2vcpu-4gb"
  dnsdomain   = module.demolab.name
  zt_network  = module.demolab.id
  zt_identity = zerotier_identity.instances["do"]
  svc         = var.svc
  zt_token    = var.zt_token
  script      = "init-zeronsd.tpl"
}

module "aws" {
  source            = "./modules/aws"
  name              = "aws"
  cidr_block        = "192.168.0.0/16"
  availability_zone = "us-east-2a"
  instance_type     = "t3.micro"
  dnsdomain         = module.demolab.name
  zt_network        = module.demolab.id
  zt_identity       = zerotier_identity.instances["aws"]
  svc               = var.svc
  script            = "init-common.tpl"
}

module "gcp" {
  source        = "./modules/gcp"
  name          = "gcp"
  ip_cidr_range = "192.168.0.0/16"
  region        = "europe-west4"
  zone          = "europe-west4-a"
  dnsdomain     = module.demolab.name
  zt_network    = module.demolab.id
  zt_identity   = zerotier_identity.instances["gcp"]
  svc           = var.svc
  script        = "init-common.tpl"
}

module "azu" {
  source              = "./modules/azu"
  name                = "azu"
  address_space       = ["192.168.0.0/16", "ace:cab:deca::/48"]
  v4_address_prefixes = ["192.168.1.0/24"]
  v6_address_prefixes = ["ace:cab:deca:deed::/64"]
  dnsdomain           = module.demolab.name
  zt_network          = module.demolab.id
  zt_identity         = zerotier_identity.instances["azu"]
  svc                 = var.svc
  script              = "init-common.tpl"
}
