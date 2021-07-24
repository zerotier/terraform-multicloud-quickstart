
locals {
  assignment_pools = flatten([
    for subnet in var.subnets : [{
      start = cidrhost(subnet, min(range(32 - split("/", subnet)[1])...) + 1)
      end   = cidrhost(subnet, pow(2, (32 - split("/", subnet)[1])) - 1)
    }]
  ])
}

locals {
  routes = var.routes
}

locals {
  subnet_routes = flatten([
    for subnet in var.subnets : [{
      target = subnet
      via    = null
    }]
  ])
}

resource "zerotier_network" "this" {
  name             = var.name
  description      = var.description
  enable_broadcast = var.enable_broadcast
  flow_rules       = var.flow_rules
  multicast_limit  = var.multicast_limit
  private          = var.private

  assign_ipv4 {
    zerotier = var.assign_ipv4.zerotier
  }

  assign_ipv6 {
    zerotier = var.assign_ipv6.zerotier
    sixplane = var.assign_ipv6.sixplane
    rfc4193  = var.assign_ipv6.rfc4193
  }

  dynamic "assignment_pool" {
    for_each = local.assignment_pools
    content {
      start = assignment_pool.value.start
      end   = assignment_pool.value.end
    }
  }

  dynamic "route" {
    for_each = flatten(concat(local.routes, local.subnet_routes))
    content {
      target = route.value.target
      via    = route.value.via
    }
  }
}
