
resource "oci_core_vcn" "this" {
  cidr_block     = "192.168.1.0/24"
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaaug2bz37uinrpcxwp7gzkaxeuejppf5obbiak7j5h34u5joig4m5q"
  display_name   = "oci"
  dns_label      = "oci"
}
