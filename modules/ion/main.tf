
data "ionoscloud_image" "this" {
  name       = "ubuntu"
  type       = "HDD"
  version    = "20.04-LTS-server-cloud-init.qcow2"
  location   = "de/txl"
  cloud_init = "V1"
}

resource "ionoscloud_datacenter" "this" {
  name        = "hello"
  location    = "de/txl"
  description = "hello"
}

resource "ionoscloud_lan" "this" {
  datacenter_id = ionoscloud_datacenter.this.id
  public        = true
}

resource "ionoscloud_ipblock" "this" {
  name     = "this"
  location = ionoscloud_datacenter.this.location
  size     = 1
}

resource "ionoscloud_server" "this" {
  name              = "this"
  datacenter_id     = ionoscloud_datacenter.this.id
  cores             = 1
  ram               = 1024
  availability_zone = "ZONE_1"
  cpu_family        = "INTEL_SKYLAKE"
  image_password    = "Ch4ng3m3"
  image_name        = data.ionoscloud_image.this.id

  volume {
    name      = "new"
    size      = 5
    disk_type = "SSD"
    user_data = data.cloudinit_config.this.rendered
  }

  nic {
    lan             = ionoscloud_lan.this.id
    dhcp            = true
    ips             = ["${ionoscloud_ipblock.this.ips[0]}"]
    firewall_active = true
  }
}

data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "dnsdomain"   = var.dnsdomain
      "hostname"    = var.name
      "pod_cidr"    = var.pod_cidr
      "svc"         = var.svc
      "zeronsd"     = var.zeronsd
      "zt_identity" = var.zt_identity
      "zt_network"  = var.zt_network
      "zt_token"    = var.zt_token
    })
  }
}
