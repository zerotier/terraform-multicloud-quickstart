
variable "ip_cidr_range" {
  type = string
}

variable "name" {
  type = string
  validation {
    condition     = can(regex("[a-z]([-a-z0-9]*[a-z0-9])?", var.name))
    error_message = "Name must match regex [a-z]([-a-z0-9]*[a-z0-9])?"
  }
}

variable "network" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "secondary_ip_range" {
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = null
}

variable "private_ip_google_access" {
  type    = bool
  default = false
}

variable "private_ipv6_google_access" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "log_config" {
  type = object({
    aggregation_interval = string
    flow_sampling        = string
    metadata             = string
    metadata_fields      = string
    filter_expr          = string
  })
  default = null
}
