
resource "azurerm_virtual_network" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  address_space         = var.address_space
  location              = var.location
  bgp_community         = var.bgp_community
  dns_servers           = var.dns_servers
  vm_protection_enabled = var.vm_protection_enabled
  tags                  = var.tags
}
