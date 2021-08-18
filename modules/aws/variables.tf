variable "availability_zone" {
  default = "us-east-2a"
}

variable "aws_ami" {
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
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
  type = string
}

variable "script" {
  type = string
}

variable "svc" {
  type = map(map(string))
}

variable "zt_identity" {
  sensitive = true
}

variable "zt_networks" {
  type = map(map(string))
}
