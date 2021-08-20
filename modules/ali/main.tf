data "alicloud_instance_type_families" "default" {
  instance_charge_type = "PostPaid"
}

data "alicloud_instance_types" "this" {
  instance_type_family = "ecs.g6"
  cpu_core_count       = 2
}

data "alicloud_zones" "this" {
  available_disk_category = "cloud_ssd"
  available_instance_type = data.alicloud_instance_types.this.instance_types[0].id
}

resource "alicloud_vpc" "this" {
  vpc_name    = var.name
  cidr_block  = "192.168.0.0/16"
}

resource "alicloud_vswitch" "this" {
  zone_id      = data.alicloud_zones.this.zones[0].id
  vswitch_name = "ali"
  cidr_block   = "192.168.1.0/24"
  vpc_id       = alicloud_vpc.this.id
}

resource "alicloud_security_group" "this" {
  name   = "ali"
  vpc_id = alicloud_vpc.this.id
}

resource "alicloud_security_group_rule" "allow_all" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "9993/9993"
  priority          = 1
  security_group_id = alicloud_security_group.this.id
  cidr_ip           = "0.0.0.0/0"
}

data "template_cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/${var.script}", {
      "hostname"    = var.name
      "dnsdomain"   = var.dnsdomain
      "zt_identity" = var.zt_identity
      "zt_networks" = var.zt_networks
      "svc"         = var.svc
    })
  }
}

resource "alicloud_instance" "this" {
  instance_name        = "ali"
  host_name            = "ali.demo.lab"
  image_id             = "ubuntu_20_04_x64_20G_alibase_20210623.vhd"
  instance_type        = data.alicloud_instance_types.this.instance_types[0].id
  security_groups      = [alicloud_security_group.this.id]
  vswitch_id           = alicloud_vswitch.this.id
  internet_charge_type = "PayByTraffic"
  password             = "N3wZ3r0T13r!"
  instance_charge_type = "PostPaid"
  tags                 = { "Name" : "ali" }
  user_data            = data.template_cloudinit_config.this.rendered
}

resource "alicloud_eip" "this" {
  bandwidth            = "10"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "this" {
  allocation_id = alicloud_eip.this.id
  instance_id   = alicloud_instance.this.id
}
