
variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "propagating_vgws" {
  type    = list(string)
  default = null
}
