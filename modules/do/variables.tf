
variable "image" {
  default = "ubuntu-20-04-x64"
  type    = string
}

variable "name" {
  default = "do"
  type    = string
}

variable "region" {
  default = "fra1"
  type    = string
}

variable "size" {
  default = "s-2vcpu-4gb"
  type    = string
}

variable "zt_networks" {
  type = map(map(string))
}

variable "zt_identity" {
}

variable "svc" {
}

variable "zt_token" {
}

variable "dnsdomain" {
}

variable "script" {
}
