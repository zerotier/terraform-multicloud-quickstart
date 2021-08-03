
variable "image" {
  type = string
}

variable "size" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "ipv6" {
  type = bool
}
variable "tags" {
  default = []
}

variable "user_data" {
  sensitive = true
}

resource "digitalocean_droplet" "this" {
  image     = var.image
  size      = var.size
  name      = var.name
  region    = var.region
  ipv6      = var.ipv6
  tags      = var.tags
  user_data = var.user_data
}
