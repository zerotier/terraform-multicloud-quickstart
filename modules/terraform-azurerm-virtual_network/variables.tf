
variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "location" {
  type = string
}

variable "bgp_community" {
  type    = string
  default = null
}

variable "dns_servers" {
  type    = list(string)
  default = null
}

variable "vm_protection_enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
