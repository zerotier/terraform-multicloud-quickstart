

resource "azurerm_network_interface" "this_primary" {
  name                = "${var.name}-primary"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.name}-primary"
    subnet_id                     = var.subnet_id
    private_ip_address_version    = var.private_ip_address_version
    private_ip_address_allocation = var.private_ip_address_allocation
    public_ip_address_id          = var.public_ip_address_id
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.this_primary.id
  ]

  admin_ssh_key {
    public_key = tls_private_key.this.public_key_openssh
    username   = "deleteme"
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }

  custom_data = var.custom_data
}
