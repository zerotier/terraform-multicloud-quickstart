
locals {
  azu_name     = "azu"
  azu_location = "brazilsouth"
}

resource "azurerm_resource_group" "this" {
  location = local.azu_location
  name     = local.azu_name
}

resource "azurerm_public_ip" "this_v4" {
  name                = "${local.azu_name}-v4"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "this_v6" {
  name                = "${local.azu_name}-v6"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv6"
}

resource "azurerm_virtual_network" "this" {
  name                = local.azu_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["192.168.0.0/16", "ace:cab:deca::/48"]
}

resource "azurerm_subnet" "this_v4" {
  name                 = "${local.azu_name}-zone-00-v4"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "this_v6" {
  name                 = "${local.azu_name}-zone-00-v6"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["ace:cab:deca:deed::/64"]
}

resource "azurerm_network_interface" "this" {
  name                          = local.azu_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  enable_ip_forwarding          = true
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "${local.azu_name}-v4"
    subnet_id                     = azurerm_subnet.this_v4.id
    public_ip_address_id          = azurerm_public_ip.this_v4.id
    private_ip_address_allocation = "Dynamic"
    primary                       = "true"
  }

  ip_configuration {
    name                          = "${local.azu_name}-v6"
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
  name                = local.azu_name
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
    content      = templatefile("${path.module}/tpl/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/tpl/hostname.tpl", {
      "hostname" = local.azu_name,
      "fqdn"     = "${local.azu_name}.${local.dnsdomain}"
    })
  }

  part {
    filename     = "ssh.cfg"
    content_type = "text/cloud-config"
    content      = <<EOF
ssh_publish_hostkeys:
    enabled: true
no_ssh_fingerprints: false
ssh_keys:
  ${lower(tls_private_key.azu.algorithm)}_private: |
    ${indent(4, chomp(tls_private_key.azu.private_key_pem))}
  ${lower(tls_private_key.azu.algorithm)}_public: |
    ${indent(4, chomp(tls_private_key.azu.public_key_openssh))}
EOF
  }

  part {
    filename     = "zerotier.cfg"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/tpl/writefiles.tpl", {
        "files" = [
          {
            "path"    = "/var/lib/zerotier-one/identity.public",
            "mode"    = "0644",
            "content" = zerotier_identity.instances["azu"].public_key
          },
          {
            "path"    = "/var/lib/zerotier-one/identity.secret",
            "mode"    = "0600",
            "content" = zerotier_identity.instances["azu"].private_key
          }
        ]
    })
  }

  part {
    filename     = "init-common.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/tpl/init-common.tpl", {
      "dnsdomain"  = local.dnsdomain
      "zt_network" = module.demolab.id
    })
  }
}
