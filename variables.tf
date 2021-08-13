
variable "enabled" {
  default = {
    do  = true #-- required (provides DNS)
    aws = true
    gcp = true
    azu = true
  }
}

variable "svc" {
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
