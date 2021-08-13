variable "svc" {
  default = {
    someara = {
      username   = "someara"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINv7jD5KZu6lEVbHvzS+w+eQeuZGfY3jBaW7y5qftF1u sean@sean.io"
    }
  }
}

variable "enabled" {
  default = {
    do  = true
    aws = true
    gcp = true
    azu = true
  }
}

variable "people" {
  default = {
    # api = {
    #   member_id   = "bcbad4fd5a"
    #   description = "Adam Ierymenko"
    # }
    # joseph = {
    #   member_id   = "f55311dff0"
    #   description = "Joseph Henry"
    # }
    # glimberg = {
    #   member_id   = "46d7c837f0"
    #   description = "Grant Limberg"
    # }
    # laduke = {
    #   member_id   = "9935981b1e"
    #   description = "Travis LaDuke"
    # }
    # gcastle = {
    #   member_id   = "b5b260f06b"
    #   description = "Greg Castle"
    # }
    # steve = {
    #   member_id   = "7deec4fcdc"
    #   description = "Steve Norman"
    # }
    someara = {
      member_id   = "eff05def90"
      description = "Sean OMeara"
    }
    # joy = {
    #   member_id   = "83e1529567"
    #   description = "Joy Larkin"
    # }
    # dennisk = {
    #   member_id   = "0f445b05f4"
    #   description = "Dennis Kittrel"
    # }
    # erikh = {
    #   member_id   = "7d22465c2b"
    #   description = "Erik Hollensbe"
    # }
  }
}
