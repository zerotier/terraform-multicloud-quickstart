
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

variable "instances" {
  default = {
    do = {
      description   = "Digital Ocean"
      ip_assignment = "10.4.2.1"
      enabled       = true
    }
    aws = {
      description   = "Amazon Web Services"
      ip_assignment = "10.4.2.2"
      enabled       = true
    }
    gcp = {
      description   = "Google Compute Platform"
      ip_assignment = "10.4.2.3"
      enabled       = false
    }
    azu = {
      description   = "Microsoft Azure"
      ip_assignment = "10.4.2.4"
      enabled       = false
    }
    oci = {
      description   = "Oracle Cloud Infrastructure"
      ip_assignment = "10.4.2.5"
      enabled       = false
    }
    ibm = {
      description   = "IBM Cloud"
      ip_assignment = "10.4.2.6"
      enabled       = false
    }
    vul = {
      description   = "Vultr"
      ip_assignment = "10.4.2.7"
      enabled       = false
    }
    ali = {
      description   = "Alibaba Cloud"
      ip_assignment = "10.4.2.8"
      enabled       = false
    }
    eqx = {
      description   = "Equinix Metal"
      ip_assignment = "10.4.2.9"
      enabled       = false
    }
  }
}
