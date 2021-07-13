
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
    content      = <<EOF
hostname: qs-do-fra
fqdn: qs-do-fra.demo.lab
manage_etc_hosts: true
EOF
  }
}
