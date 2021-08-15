variable "dnsdomain" {}

variable "zt_networks" {
  type = map(map(string))
}

variable "zt_identity" {}

variable "location" {
  default = "eastus"
}

variable "name" {
  default = "azu"
}

variable "svc" {}

variable "address_space" {
  default = ["192.168.0.0/16", "ace:cab:deca::/48"]
}

variable "v4_address_prefixes" {
  default = ["192.168.1.0/24"]
}

variable "v6_address_prefixes" {
  default = ["ace:cab:deca:deed::/64"]
}

variable "script" {}
