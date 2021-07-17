
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

resource "azurerm_public_ip" "this" {
  name                = "azu"
  resource_group_name = azurerm_resource_group.this.name
  location            = "westeurope"
  sku                 = "Basic"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

resource "azurerm_network_interface" "this" {
  name                = "azu"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "azu"
    subnet_id                     = azurerm_subnet.this.id
    public_ip_address_id          = azurerm_public_ip.this.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "azu-rsa" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "azu"
  resource_group_name = azurerm_resource_group.this.name
  location            = "westeurope"
  size                = "Standard_B1ls"
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

resource "tls_private_key" "azu" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

data "template_cloudinit_config" "azu" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "service_account.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/users.tpl", { "svc" = var.svc })
  }

  part {
    filename     = "hostname.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/hostname.tpl", {
      "hostname" = "azu",
      "fqdn"     = "azu.demo.lab"
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
      "${path.module}/writefiles.tpl", {
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
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/init-azu.tpl", { "zt_network" = module.demolab.id })
  }
}
