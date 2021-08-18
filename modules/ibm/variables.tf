variable "name" {}
variable "dnsdomain" {}
variable "zt_networks" {}
variable "zt_identity" { sensitive = true }
variable "svc" {}
variable "script" {}
variable "vpc_cidr" { type = string }
variable "subnet_cidr" { type = string }
variable "zone" { default = "us-east-1" }
variable "instance_profile" { default = "cx2-2x4" }
variable "image" { default = "ibm-ubuntu-20-04-2-minimal-amd64-1" }
