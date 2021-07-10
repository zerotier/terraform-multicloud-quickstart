terraform {
  required_providers {
    tls = {
      source  = "someara/tls"
      version = "2.3.0-pre"
    }
    zerotier = {
      source  = "zerotier/zerotier"
      version = "~> 0.1.47"
    }
  }
  # required_version = ">= 0.14"
}
