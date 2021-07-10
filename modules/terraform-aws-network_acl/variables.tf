
variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "ingress" {
  default = null
}

variable "egress" {
  default = null
}
variable "tags" {
  default = {}
}
