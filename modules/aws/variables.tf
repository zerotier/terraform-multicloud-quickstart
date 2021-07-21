variable "availability_zone" {
  default = "us-east-2a"
}

variable "cidr_block" {
  default = "192.168.0.0/16"
}

variable "dnsdomain" {
  default = "demo.lab"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "name" {
  default = "aws"
}

variable "zt_network" {}
variable "zt_identity" {}
variable "svc" {}
variable "script" {}
