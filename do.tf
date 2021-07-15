
resource "digitalocean_vpc" "example" {
  name     = "quickstart"
  region   = "fra1"
  ip_range = "10.1.0.0/16"
}

resource "digitalocean_droplet" "this" {
  image     = "ubuntu-20-04-x64"
  size      = "s-1vcpu-1gb"
  name      = "qs-do-fra"
  region    = "fra1"
  vpc_uuid  = digitalocean_vpc.example.id
  tags      = []
  user_data = data.template_cloudinit_config.do.rendered
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
    content      = templatefile("${path.module}/init-do.tpl", { "zt_network" = module.demolab.id })
  }
}
