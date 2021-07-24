module "this" {
  for_each    = var.zerotier_networks
  source      = "../../"
  name        = each.key
  description = each.value.description
  subnets     = each.value.subnets
  flow_rules  = each.value.flow_rules
}

output "this" {
  value = module.this
}
