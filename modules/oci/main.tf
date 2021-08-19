
resource "oci_core_vcn" "this" {
  cidr_block     = "192.168.0.0/16"
  compartment_id = var.compartment_id
  display_name   = var.name
  dns_label      = var.name
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  display_name   = var.name
  vcn_id         = oci_core_vcn.this.id
}

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.name

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "17"
    source   = "0.0.0.0/0"
    udp_options {
      min = "9993"
      max = "9993"
    }
  }
}

resource "oci_core_subnet" "test_subnet" {
  cidr_block        = "192.168.1.0/24"
  display_name      = var.name
  dns_label         = var.name
  security_list_ids = [oci_core_security_list.this.id]
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.this.id
  route_table_id    = oci_core_route_table.this.id
  dhcp_options_id   = oci_core_vcn.this.default_dhcp_options_id
}

data "oci_identity_availability_domain" "this" {
  compartment_id = var.compartment_id
  ad_number      = 2
}

resource "oci_core_instance" "this" {
  availability_domain = data.oci_identity_availability_domain.this.name
  compartment_id      = var.compartment_id
  display_name        = var.name
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.test_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = var.name
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.iad.aaaaaaaayfc7vgsvgtmrlka74mdhyawbjmpcllntrowcuimb6nfxyqur734q"
  }

  metadata = {
    user_data = data.template_cloudinit_config.this.rendered
  }
}

data "template_cloudinit_config" "this" {
  gzip          = false
  base64_encode = true

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
