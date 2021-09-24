
output "networks" {
  value = {
    demolab = zerotier_network.demolab.id
  }
}

output "identities" {
  value = {
    for k, v in zerotier_identity.instances :
    k => v.id
  }
}
