
resource "alicloud_vpc" "this" {
  vpc_name   = "ali"
  cidr_block = "192.168.1.0/24"
}
