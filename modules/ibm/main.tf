

data "ibm_resource_group" "this" {
  name = "Default"
}

resource "ibm_is_vpc" "this" {
  name                      = "ibm"
  resource_group            = data.ibm_resource_group.this.id
  address_prefix_management = "manual"
}

# resource "ibm_is_subnet" "frontend_subnet" {
#   name            = "ibm"
#   vpc             = ibm_is_vpc.this.id
#   zone            = "${var.ibm_region}-${count.index % 3 + 1}"
#   ipv4_cidr_block = "192.168.1.0/24"
#   # network_acl     = "${ibm_is_network_acl.multizone_acl.id}"
#   public_gateway = ibm_is_public_gateway.repo_gateway[count.index].id
#   depends_on     = [ibm_is_vpc_address_prefix.frontend_subnet_prefix]
# }

# resource "ibm_is_instance" "this" {
#   name    = "ibm"
#   image   = "ibm-centos-7-6-minimal-amd64-1"
#   profile = "cx2-2x4"

#   primary_network_interface {
#     subnet          = var.subnet_ids[count.index]
#     security_groups = [ibm_is_security_group.frontend.id]
#   }

#   vpc            = var.ibm_is_vpc_id
#   zone           = "${var.ibm_region}-${count.index % 3 + 1}"
#   resource_group = var.ibm_is_resource_group_id
#   keys           = [var.ibm_is_ssh_key_id]
#   tags           = ["schematics:group:frontend"]
#   #user_data      = data.template_cloudinit_config.app_userdata.rendered
# }
