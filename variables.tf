
variable "users" {
  default = {
    api = {
      username   = "api"
      ssh_pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCm1xp11CUmGVUMQyQAVHyblmPXagfCYD5a0/7UwTMdQwWrYbTTPY8gCcNBxst3ZhRNOiQ+RfNV3juh7GwjHbzJfPST2JQs5rdDXBzCiZ8bSe0AZgO39y15RjDWzUOUM6EDPpAy9WC+QvPnqbr1FcksjvyRP1QuiKoA4f1zFFpl6dsKNJwQMrrqQQM2zLM3gbjgyskxKpV7K88JzpKwOdKb/LvbshJvJ+oibhhf6Q6Ejb2NHryPEUm12RnZN40F6TpqIcACPqbCCAysnLB7+CuQn/a9N1L25FqqUdCTPjMlUEOgqUSzcelqzBFtfpuLltFCoKUe5MulGt72kyEpN3wmv9Z4U2/xLmcw7dzovqkzGKJafYxBTCfl+z3DLQoxlLZEPyM6GjJXnyJ/mIK+rxAd2PuZVpoHluTz9Hcdr3M3AEMgYB8TGNp+aqHxj0m1Pvot1phROlt7b7AzH/EaA2ckYb8Jrko9rqvFCCdVf6OL243mABPQGXX9b2fIulYHXpCdwLpjYSOy8M1npOycbK3/KSO3iSSbBmFnVuHR1HVqTUmo1g3bdqXf7jXt+fw8i77fGFjoBovug02MnJCXNI4cvEkWJijy8sC5qaaqyEpOIWOwzbvq854lkc12cIQSX4uNnVEns18/h+doMLiUJXhoNwS1LG+SKaUlxDltKW09lw== api@legba"
    }
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
    legba = {
      member_id   = "11c88a381e"
      description = "legba"
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
      enabled       = false
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
    ali = {
      description   = "Alibaba Cloud"
      ip_assignment = "10.4.2.7"
      enabled       = true
    }
    vul = {
      description   = "Vultr"
      ip_assignment = "10.4.2.8"
      enabled       = false
    }
  }
}
