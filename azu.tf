
resource "azurerm_resource_group" "this" {
  location = "westeurope"
  name     = "quickstart"
}

resource "azurerm_virtual_network" "this" {
  name                = "azu"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/16"]
  location            = "westeurope"
}

resource "azurerm_subnet" "this" {
  name                 = "azu-zone-00"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["192.168.1.0/24"]
}
