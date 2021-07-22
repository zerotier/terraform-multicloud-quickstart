variable "dnsdomain" {
}

variable "image" {
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "ip_cidr_range" {
  default = "192.168.1.0/24"
}

variable "machine_type" {
  default = "e2-medium"
}

variable "name" {
  default = "gcp"
}

variable "region" {
  default = "europe-west4"
}

variable "zone" {
  default = "europe-west4-a"
}

variable "zt_identity" {
}

variable "zt_networks" {
  type = map(map(string))
}

variable "svc" {}

variable "script" {}
