variable "zerotier_networks" {
  default = {
    overlap_one = {
      description = "Zerotier networks can have multiple subnets"
      subnets     = ["10.1.0.0/16", "10.2.0.0/16"]
      flow_rules  = "accept;"
    }
    overlap_two = {
      description = "Zerotier networks can overlap"
      subnets     = ["10.1.0.0/16", "10.2.0.0/16"]
      flow_rules  = "accept;"
    }
  }
}
