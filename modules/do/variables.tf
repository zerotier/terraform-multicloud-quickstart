
variable "image" {
  default = "ubuntu-20-04-x64"
  type    = string
}

variable "name" {
  default = "do"
  type    = string
}

variable "region" {
  default = "nyc1"
  type    = string
}

variable "size" {
  default = "s-1vcpu-1gb-amd"
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
