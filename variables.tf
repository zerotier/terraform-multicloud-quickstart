
variable "users" {
  default = {
    alice = {
      username   = "alice"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxBkqXD41K8LfyJrjf8PSrxsNqhNUlWfqIzM52iWy+B alice@sean.io"
    }
    bob = {
      username   = "bob"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPxC8oiMHeqcTH507iWJbHs/4/yx3vOOBDf/n6Eowj7 bob@sean.io"
    }
  }
}

variable "devices" {
  default = {
    laptop = {
      member_id   = "a11c3411ce"
      description = "alice laptop"
    }
    workstation = {
      member_id   = "b0bd0bb0bb"
      description = "bob's desktop"
    }
  }
}

variable "instances" {
  default = {
    do = {
      description   = "Digital Ocean"
      ip_assignment = "10.0.1.1"
      enabled       = true
    }
    aws = {
      description   = "Amazon Web Services"
      ip_assignment = "10.0.2.1"
      enabled       = true
    }
    gcp = {
      description   = "Google Compute Platform"
      ip_assignment = "10.0.3.1"
      enabled       = true
    }
    azu = {
      description   = "Microsoft Azure"
      ip_assignment = "10.0.4.1"
      enabled       = true
    }
    oci = {
      description   = "Oracle Cloud Infrastructure"
      ip_assignment = "10.0.5.1"
      enabled       = true
    }
    ibm = {
      description   = "IBM Cloud"
      ip_assignment = "10.0.6.1"
      enabled       = true
    }
    vul = {
      description   = "Vultr"
      ip_assignment = "10.0.7.1"
      enabled       = true
    }
    ali = {
      description   = "Alibaba Cloud"
      ip_assignment = "10.0.8.1"
      enabled       = true
    }
    eqx = {
      description   = "Equinix Metal"
      ip_assignment = "10.0.9.1"
      enabled       = true
    }
  }
}
