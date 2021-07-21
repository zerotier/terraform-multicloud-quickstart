variable "image" {
  default = "ubuntu-20-04-x64"
}

variable "name" {
  default = "do"
}

variable "region" {
  default = "fra1"
}

variable "size" {
  default = "s-2vcpu-4gb"
}

variable "zt_network" {}
variable "zt_identity" {}
variable "svc" {}

variable "zt_token" {}
variable "dnsdomain" {}

variable "script" {}
