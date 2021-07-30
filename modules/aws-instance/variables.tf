variable "availability_zone" {
  default = "us-east-2a"
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

variable "zt_networks" {
  type = map(map(string))
}

variable "zt_identity" {}
variable "svc" {}
variable "script" {}

variable "security_group" {}
variable "subnet" {}
