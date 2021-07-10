
variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

variable "delegation" {
  type = object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  })
  default = null
}

variable "enforce_private_link_endpoint_network_policies" {
  type    = bool
  default = false
}

variable "enforce_private_link_service_network_policies" {
  type    = bool
  default = false
}

variable "service_endpoints" {
  type    = list(string)
  default = null
}

variable "service_endpoint_policy_ids" {
  type    = list(string)
  default = null
}
