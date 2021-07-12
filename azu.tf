resource "azurerm_resource_group" "this" {
  location = "westeurope"
  name     = "qs-azu-ams"
}

resource "azurerm_virtual_network" "this" {
  name                = "qs-azu-ams"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.3.0.0/16"]
  location            = "westeurope"
}

resource "azurerm_subnet" "this" {
  name                 = "qs-azu-ams-zone-00"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.3.1.0/24"]
}
