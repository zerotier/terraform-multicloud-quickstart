variable "project" {
  default = "quickstart"
}

variable "plan" {
  default = "c3.small.x86"
}

variable "metro" {
  default = "dc"
}

variable "operating_system" {
  default = "Ubuntu 20.04 LTS"
}

variable "billing_cycle" {
  default = "hourly"
}

variable "name" {}
variable "dnsdomain" {}
variable "zt_networks" {}
variable "zt_identity" {}
variable "svc" {}
variable "script" {}
