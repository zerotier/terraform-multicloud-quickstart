
variable "availability_zone" {
  type    = string
  default = null
}

variable "availability_zone_id" {
  type    = string
  default = null
}

variable "cidr_block" {
  type    = string
  default = null
}

variable "customer_owned_ipv4_pool" {
  type    = string
  default = null
}

variable "ipv6_cidr_block" {
  type    = string
  default = null
}

variable "map_customer_owned_ip_on_launch" {
  type    = bool
  default = null
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = false
}

variable "outpost_arn" {
  type    = string
  default = null
}

variable "assign_ipv6_address_on_creation" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
