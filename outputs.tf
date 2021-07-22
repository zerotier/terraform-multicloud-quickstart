
output "networks" {
  value = {
    primary   = module.primary.id
    backplane = module.backplane.id
  }
}

output "identities" {
  value = {
    do  = zerotier_identity.instances["do"].id
    aws = zerotier_identity.instances["aws"].id
    gcp = zerotier_identity.instances["gcp"].id
    azu = zerotier_identity.instances["azu"].id
  }
}
