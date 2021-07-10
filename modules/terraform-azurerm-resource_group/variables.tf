
variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}
