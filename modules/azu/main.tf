
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.name
}

resource "azurerm_public_ip" "this_v4" {
  name                = "${var.name}-v4"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "this_v6" {
  name                = "${var.name}-v6"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv6"
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.address_space
}

resource "azurerm_subnet" "this_v4" {
  name                 = "${var.name}-zone-00-v4"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.v4_address_prefixes
}

resource "azurerm_subnet" "this_v6" {
  name                 = "${var.name}-zone-00-v6"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.v6_address_prefixes
}

resource "azurerm_network_interface" "this" {
  name                          = var.name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  enable_ip_forwarding          = true
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "${var.name}-v4"
    subnet_id                     = azurerm_subnet.this_v4.id
    public_ip_address_id          = azurerm_public_ip.this_v4.id
    private_ip_address_allocation = "Dynamic"
    primary                       = "true"
  }

  ip_configuration {
    name                          = "${var.name}-v6"
    subnet_id                     = azurerm_subnet.this_v6.id
    public_ip_address_id          = azurerm_public_ip.this_v6.id
    private_ip_address_version    = "IPv6"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "azu-rsa" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_private_key" "azu" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_D2_v4"
  admin_username      = "notroot"
  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  admin_ssh_key {
    public_key = tls_private_key.azu-rsa.public_key_openssh
    username   = "notroot"
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = data.template_cloudinit_config.azu.rendered
}

data "template_cloudinit_config" "azu" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "service_account.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/hostname.tpl", {
      "hostname" = var.name,
      "fqdn"     = "${var.name}.${var.dnsdomain}"
    })
  }

  part {
    filename     = "ssh.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/ssh.tpl", {
      "algorithm"   = lower(tls_private_key.azu.algorithm)
      "private_key" = indent(4, chomp(tls_private_key.azu.private_key_pem))
      "public_key"  = indent(4, chomp(tls_private_key.azu.public_key_openssh))
    })
  }

  part {
    filename     = "zerotier.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/zt_identity.tpl", {
      "public_key"  = var.zt_identity.public_key
      "private_key" = var.zt_identity.private_key
    })
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "dnsdomain"  = var.dnsdomain
      "zt_network" = var.zt_network
    })
  }
}
