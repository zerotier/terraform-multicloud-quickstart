
variable "enabled" {
  default = {
    do  = true #-- required (provides DNS)
    aws = false
    gcp = false
    azu = false
    ibm = false
    oci = true
    ali = true
  }
}

variable "users" {
  default = {
    someara = {
      username   = "someara"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINv7jD5KZu6lEVbHvzS+w+eQeuZGfY3jBaW7y5qftF1u sean@sean.io"
    }
  }
}

variable "devices" {
  default = {
    laptop = {
      member_id   = "eff05def90"
      description = "laptop"
    }
  }
}
