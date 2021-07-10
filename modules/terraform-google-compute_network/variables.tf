
variable "name" {
  type = string
  validation {
    condition     = can(regex("[a-z]([-a-z0-9]*[a-z0-9])?", var.name))
    error_message = "Name must match regex [a-z]([-a-z0-9]*[a-z0-9])?"
  }
}

variable "description" {
  type    = string
  default = null
}

variable "auto_create_subnetworks" {
  type    = bool
  default = false
}

variable "routing_mode" {
  type    = string
  default = "REGIONAL"
  validation {
    condition     = can(contains(["REGIONAL", "GLOBAL"], var.routing_mode))
    error_message = "The routing_mode must be either REGIONAL or GLOBAL."
  }
}

variable "mtu" {
  type    = number
  default = null
}

variable "project" {
  type    = string
  default = null
}

variable "delete_default_routes_on_create" {
  type    = bool
  default = false
}
