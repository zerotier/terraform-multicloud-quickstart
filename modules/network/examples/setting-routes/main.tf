module "this" {
  for_each    = var.zerotier_networks
  source      = "../../"
  name        = each.key
  description = each.value.description
  subnets     = each.value.subnets
  routes      = each.value.routes
  flow_rules  = each.value.flow_rules
}
