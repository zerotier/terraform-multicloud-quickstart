
resource "digitalocean_droplet" "this" {
  image     = "ubuntu-20-04-x64"
  size      = "s-2vcpu-4gb"
  name      = "do"
  region    = "fra1"
  tags      = []
  user_data = data.template_cloudinit_config.do.rendered
}

resource "tls_private_key" "do" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

data "template_cloudinit_config" "do" {
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
      "hostname" = "do",
      "fqdn"     = "do.demo.lab"
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
  ${lower(tls_private_key.do.algorithm)}_private: |
    ${indent(4, chomp(tls_private_key.do.private_key_pem))}
  ${lower(tls_private_key.do.algorithm)}_public: |
    ${indent(4, chomp(tls_private_key.do.public_key_openssh))}
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
            "content" = zerotier_identity.instances["do"].public_key
          },
          {
            "path"    = "/var/lib/zerotier-one/identity.secret",
            "mode"    = "0600",
            "content" = zerotier_identity.instances["do"].private_key
          }
        ]
    })
  }

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/init-do.tpl", {
      "dnsdomain"  = "demo.lab"
      "zt_network" = module.demolab.id
      "zt_token"   = "kD4OJXIHvP72MZyOyI0eKIuT7xc3W59x"
    })
  }
}
