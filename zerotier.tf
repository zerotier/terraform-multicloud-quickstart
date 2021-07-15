
module "demolab" {
  source      = "zerotier/network/zerotier"
  version     = "0.0.17"
  name        = "demo.lab"
  description = "ZeroTier Demo Lab"
  subnets     = ["10.9.8.0/24"]
  flow_rules  = "accept;"
}

resource "zerotier_member" "devices" {
  for_each = {
    # api = {
    #   member_id   = "bcbad4fd5a"
    #   description = "Adam Ierymenko"
    # }
    # joseph = {
    #   member_id   = "f55311dff0"
    #   description = "Joseph Henry"
    # }
    # glimberg = {
    #   member_id   = "46d7c837f0"
    #   description = "Grant Limberg"
    # }
    # laduke = {
    #   member_id   = "9935981b1e"
    #   description = "Travis LaDuke"
    # }
    # gcastle = {
    #   member_id   = "b5b260f06b"
    #   description = "Greg Castle"
    # }
    # steve = {
    #   member_id   = "7deec4fcdc"
    #   description = "Steve Norman"
    # }
    someara = {
      member_id   = "eff05def90"
      description = "Sean OMeara"
    }
    # joy = {
    #   member_id   = "83e1529567"
    #   description = "Joy Larkin"
    # }
    # dennisk = {
    #   member_id   = "0f445b05f4"
    #   description = "Dennis Kittrel"
    # }
  }
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
  ] : i => (i) }
}

resource "zerotier_member" "instances" {
  for_each   = zerotier_identity.instances
  name       = each.key
  member_id  = each.value.id
  network_id = module.demolab.id
}
