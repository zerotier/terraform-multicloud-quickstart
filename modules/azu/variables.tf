
variable "name" {
  type = string
}

variable "location" {
  default = "eastus"
}

variable "address_space" {
  default = ["192.168.0.0/16", "ace:cab:deca::/48"]
}

variable "v4_address_prefixes" {
  default = ["192.168.1.0/24"]
}

variable "v6_address_prefixes" {
  default = ["ace:cab:deca:deed::/64"]
}

variable "dnsdomain" {
  type = string
}

variable "script" {
  type = string
}

variable "svc" {
  type = map(
    object({
      username   = string
      ssh_pubkey = string
  }))

  validation {
    condition     = alltrue([for u in var.svc : can(regex("^ssh-", u.ssh_pubkey))])
    error_message = "The ssh_pubkey value must be a valid ssh pubkey, starting with \"ssh-\"."
  }
}

variable "pod_cidr" {
  type = string
}

variable "zeronsd" {
  default = false
}

variable "zt_identity" {
  type = object({
    id          = string
    private_key = string
    public_key  = string
  })

  validation {
    condition     = length(var.zt_identity.id) == 10
    error_message = "The zt_identity id must be be 10 characters long."
  }

  sensitive = true
}

variable "zt_network" {
  type = string

  validation {
    condition     = length(var.zt_network) == 16
    error_message = "The zt_network id must be be 16 characters long."
  }
}

variable "zt_token" {
  type    = string
  default = "01234567890123456789012345678912"

  validation {
    condition     = length(var.zt_token) == 32
    error_message = "The zt_token must be be 32 characters long."
  }
}
