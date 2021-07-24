variable "zerotier_networks" {
  default = {
    default_route = {
      description = "Zerotier networks can set routes"
      subnets     = ["10.1.0.0/16", "10.2.0.0/16"]
      routes      = [{ target = "0.0.0.0/0", via = "10.1.0.1" }]
      flow_rules  = "accept;"
    }
  }
}
