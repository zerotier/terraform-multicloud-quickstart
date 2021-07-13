
resource "zerotier_network" "occams_router" {
  name        = "occams_router"
  description = "The prefix with largest number of bits is usually correct"
  assignment_pool {
    cidr = "10.0.0.0/24"
  }
  route {
    target = "10.0.0.0/24"
  }
  flow_rules = "accept;"
}
