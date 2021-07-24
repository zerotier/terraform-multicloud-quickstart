# ZeroTier Network Terraform Module

ZeroTier lets you connect machines, containers, and programs to
encrypted virtual LANs over the Internet. ZeroTier provides NAT
traversal, flow control rules, multipath, and more, without the hassle
of having to manage TLS keys. It supports IPv4, IPv6, as well as any
other protocol that runs on Ethernet, such as mDNS, FCoE, SCCP, IPX,
BGP or OSPF.

## Conceptual Prerequisites

- ZeroTier `Networks` can be thought of as virtual Ethernet switches that run
  on the Internet. These switches can provision IPv4 and IPv6
  addresses from pools. Networks IDs look like `abcdef1234567890`.
- `Nodes` are clients, usually running the
  [ZeroTier Client](https://www.zerotier.com/download/). Nodes "plug
  themselves in" to these switches with they attempt to join the
  network. Nodes have `Identities`, which  are shorter, and look
  something like `abcdef1234`.
- `Members` are associations between `Networks` and `Nodes`,
  representing the switch administrator authorizing the node to be on
  the network. IP addresses can optionally be configured on a
  per-membership basis, instead of being assigned from a pool.
- `Node Controllers` manage
  [Flow Control Rules](https://www.zerotier.com/manual/#3), Assignment
  Pools, Networks, and Memberships. [ZeroTier Central](https://my.zerotier.com) is our SaaS
  offering, which is driven by the
  [ZeroTier Terraform Provider](https://registry.terraform.io/providers/zerotier/zerotier/latest).
  
## Usage

Before we begin, we will need to log into [my.zerotier.com](https://my.zerotier.com) and create an API
token under the [Account](https://my.zerotier.com/account) section.

![](https://i.imgur.com/h28WRpz.png)

This token will need to exported as the `ZEROTIER_CENTRAL_TOKEN` variable in your shell or
Terraform workspace, if using
[Terraform Cloud](https://app.terraform.io/) or
[Terraform Enterprise](https://www.terraform.io/docs/enterprise/index.html).

Finally, we're able to write create some Zerotier Networks with
Terraform. Create a directory and place a `main.tf` inside of it.

```
$ mkdir -p examples/single-network && cd examples/single-network
$ emacs main.tf
```

Add the following to your `main.tf`

```hcl
module "network" {
  source      = "zerotier/network/zerotier"
  version     = "0.1.0"
  name        = "hello_zerotier"
  description = "Hello ZeroTier!"
  subnets     = ["10.9.8.0/24"]
  flow_rules  = "accept;"
}
```

Next, run initialize and plan your Terraform run with `terraform init && terraform plan`.
You should see something like this:

```
Terraform will perform the following actions:

  # module.this["hello_zerotier"].zerotier_network.this will be created
  + resource "zerotier_network" "this" {
      + assign_ipv4      = {
          + "zerotier" = true
        }
      + assign_ipv6      = {
          + "rfc4193"  = true
          + "sixplane" = false
          + "zerotier" = true
        }
      + creation_time    = (known after apply)
      + description      = "Hello Zerotier!"
      + enable_broadcast = true
      + flow_rules       = "accept;"
      + id               = (known after apply)
      + mtu              = 2800
      + multicast_limit  = 32
      + name             = "hello_zerotier"
      + private          = true
      + tf_last_updated  = (known after apply)

      + assignment_pool {
          + end   = "10.9.8.255"
          + start = "10.9.8.1"
        }

      + route {
          + target = "10.9.8.0/24"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

Finally, run the `terraform apply`. You will see terraform creating the
network.

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.this["hello_zerotier"].zerotier_network.this: Creating...
module.this["hello_zerotier"].zerotier_network.this: Creation complete after 1s [id=8bd5124fd644aa82]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Check that it was created in the [ZeroTier Central Webui](my.zerotier.com)  

![](https://i.imgur.com/V5N04ew.png)

**Congratulations!** You have now created your first ZeroTier Network
using Infrastructure As Code with Terraform.

# Memberships

Alice can now join our network from her laptop. However, until we
authorize her to be on the network, she will not have access.

![](https://i.imgur.com/f8RXO0b.png)

Alternatively she could do so from her CLI.

```
$ zerotier-cli join 8286ac0e475d8abe
```

Alice can be authorized by creating a `Membership` objectin the
API. Her laptop will be Auto-Assigned an IP by ZeroTier in the range
`10.9.8.*.`

```hcl
module "member" {
  source      = "zerotier/member/zerotier"
  version     = "0.1.0"
  name        = "alice"
  description = "alice's laptop"
  member_id   = "ABCDEF1234"
  network_id  = module.network.id
}
```
