
variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
