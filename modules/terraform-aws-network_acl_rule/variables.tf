
variable "network_acl_id" {
  type = string
}

variable "rule_number" {
  type = number
}

variable "egress" {
  type    = bool
  default = false
}

variable "protocol" {
  type    = string
  default = "-1"
}

variable "rule_action" {
  type = string
  validation {
    condition     = can(contains(["allow", "deny"], var.rule_action))
    error_message = "The address type must be one of allow or deny."
  }
}

variable "cidr_block" {
  type    = string
  default = null
}

variable "ipv6_cidr_block" {
  type    = string
  default = null
}

variable "from_port" {
  type    = string
  default = null
}

variable "to_port" {
  type    = string
  default = null
}

variable "icmp_type" {
  type    = string
  default = null
}

variable "icmp_code" {
  type    = string
  default = null
}
