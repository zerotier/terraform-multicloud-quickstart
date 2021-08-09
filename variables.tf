variable "svc" {
  default = {
    someara = {
      username   = "someara"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINv7jD5KZu6lEVbHvzS+w+eQeuZGfY3jBaW7y5qftF1u sean@sean.io"
    }
    laduke = {
      username   = "laduke"
      ssh_pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKOSsC3TNQvUnm+3EH8X/DjYqMsytrdV0Ocx3YzZOsRlF85tEO8FOeiucr03pdzZeg8XoNtFJ4ber5HhgHIx3jdHmV08/5GYWz7nv5WFxMdgCdyUrFzrD64K/fOzWat1OH6YrTuND5dghhdD0mW/N75B2XIt1Z/bXlnFwKQCCMVmgybhMyNcgSdSCgWEPXtyIHeOd7Rvh5+ZD9nvIkIdQuzXci/oT+xSiJaDzSAVeds7SDDH/diPsbcDqaILotb4nmcD4K266SUVMh37s/4yaYIebdrFtiJOSVvttCDO7KGYPXOoGSP7TqAar9dS+/+0FW156m3R+yFEm1IlUB9ZVab/6HX1farbHtNQKCya/3vyvS+y0ehCYEWMrkJXkFrLBUaCkPW3hIlRbmS7njyyYNkvgLHjtpgdaZN7O8jTHKrYb+/GlVZLvTfx5FChjLfprf272HV1L2aw4cNdOszI3aBC2t+2hbcRB2O7jo6bO10RQwdz5t2T5BvIQc6gwYjFqRJsYqKEuf5Nb2rbLrICdphjlDxzaJa4EuKSr6XnLCWHZvgNvBTMQ4uwVFkNZ2KtWWGXpbXr7Lb9zagabgLBfp2XamNvtLejHSXkb68md4oIAejdvOl2GZmOa1g6AZC0D3yJ836ZkBwA/TrvIyaHMgvUqrvmPVdkjzUUUfGThbRQ== travisladuke@gmail.com"
    }
    api = {
      username = "api"
      ssh_pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCm1xp11CUmGVUMQyQAVHyblmPXagfCYD5a0/7UwTMdQwWrYbTTPY8gCcNBxst3ZhRNOiQ+RfNV3juh7GwjHbzJfPST2JQs5rdDXBzCiZ8bSe0AZgO39y15RjDWzUOUM6EDPpAy9WC+QvPnqbr1FcksjvyRP1QuiKoA4f1zFFpl6dsKNJwQMrrqQQM2zLM3gbjgyskxKpV7K88JzpKwOdKb/LvbshJvJ+oibhhf6Q6Ejb2NHryPEUm12RnZN40F6TpqIcACPqbCCAysnLB7+CuQn/a9N1L25FqqUdCTPjMlUEOgqUSzcelqzBFtfpuLltFCoKUe5MulGt72kyEpN3wmv9Z4U2/xLmcw7dzovqkzGKJafYxBTCfl+z3DLQoxlLZEPyM6GjJXnyJ/mIK+rxAd2PuZVpoHluTz9Hcdr3M3AEMgYB8TGNp+aqHxj0m1Pvot1phROlt7b7AzH/EaA2ckYb8Jrko9rqvFCCdVf6OL243mABPQGXX9b2fIulYHXpCdwLpjYSOy8M1npOycbK3/KSO3iSSbBmFnVuHR1HVqTUmo1g3bdqXf7jXt+fw8i77fGFjoBovug02MnJCXNI4cvEkWJijy8sC5qaaqyEpOIWOwzbvq854lkc12cIQSX4uNnVEns18/h+doMLiUJXhoNwS1LG+SKaUlxDltKW09lw== api@legba"
    }
  }
}

variable "enabled" {
  default = {
    do  = true
    aws = false
    gcp = false
    azu = false
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
