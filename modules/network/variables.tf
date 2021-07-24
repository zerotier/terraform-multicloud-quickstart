variable "name" {
  type = string
}

variable "assign_ipv4" {
  description = "IPv4 Auto-Assign."
  type = object({
    zerotier = bool
  })
  default = {
    zerotier = true
  }
}

variable "assign_ipv6" {
  description = "IPv6 Auto-Assign."
  type = object({
    zerotier = bool,
    sixplane = bool,
    rfc4193  = bool
  })
  default = {
    zerotier = true
    sixplane = false
    rfc4193  = true
  }
}

variable "description" {
  description = "The Description."
  type        = string
  default     = "Managed by Terraform"
}

variable "enable_broadcast" {
  description = "Enable broadcast."
  type        = bool
  default     = true
}

variable "flow_rules" {
  description = "Network rules engine specifcation."
  type        = string
  default     = "drop;"
}

# variable "mtu" {
#   description = "Maxiumum Transmission Unit."
#   type        = number
#   default     = 2800
# }

variable "multicast_limit" {
  description = "Multicast Limit."
  type        = number
  default     = 32
}

variable "private" {
  description = "Private or Public network"
  default     = true
}

variable "routes" {
  description = "Routes to be pushed down to client."
  type = list(object({
    target = string
    via    = string
  }))
  validation {
    condition     = can([for r in var.routes : regex("([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])/([0-9]|[12][0-9]|3[012])", r.target)])
    error_message = "Route targets should be a valid IPv4 CIDR."
  }
  validation {
    condition     = can([for r in var.routes : regex("([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])", r.via)])
    error_message = "Route via should be a valid IPv4 address."
  }
  default = []
}

variable "subnets" {
  description = "Subnet CIDR Ranges."
  type        = list(string)
  default     = []
}
