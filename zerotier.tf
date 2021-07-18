
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
  flow_rules = <<EOF
drop not ethertype ipv4 and not ethertype arp and not ethertype ipv6;
tee -1 ${zerotier_identity.instances["do"].id};
accept;
EOF
}

resource "zerotier_member" "devices" {
  for_each    = var.devices
  name        = each.key
  member_id   = each.value.member_id
  description = each.value.description
  network_id  = module.demolab.id
}

resource "zerotier_identity" "instances" {
  for_each = { for i in [
    "do",
    "aws",
    "gcp",
    "azu"
  ] : i => (i) }
}

resource "zerotier_member" "instances" {
  for_each   = zerotier_identity.instances
  name       = each.key
  member_id  = each.value.id
  network_id = module.demolab.id
}
