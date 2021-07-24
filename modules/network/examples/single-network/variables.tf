variable "zerotier_networks" {
  default = {
    hello_zerotier = {
      description = "Hello Zerotier!"
      subnets     = ["10.9.76.0/24"]
      flow_rules  = "accept;"
    }
  }
}
