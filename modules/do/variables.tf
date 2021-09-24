
variable "name" {
  type = string
}

variable "image" {
  default = "ubuntu-20-04-x64"
  type    = string
}

variable "region" {
  default = "nyc1"
  type    = string
}

variable "size" {
  default = "s-1vcpu-1gb-amd"
  type    = string
}

variable "dnsdomain" {
  type = string
}

variable "pod_cidr" {
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
