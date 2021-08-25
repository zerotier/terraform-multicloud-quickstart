# ZeroTier Terraform Quickstart

## WORK IN PROGRESS

<p align="center">
<img src="https://avatars.githubusercontent.com/u/4173285?s=200&v=4" alt="ZeroNSD" /><br/>
<b><i>
We are living in an ephemeral world<br/>
And I am an ephemeral girl<br/>
</i></b>
</p>

## Conceptual Prerequisites

* ZeroTier Networks are objects in the Central API.
* ZeroTier Identities are cryptographic identities of nodes; machines, containers, or binaries.
* ZeroTier Members are associations between Networks and Identities.
* ZeroTier virtualizes at L1 and L2 (ethernet).

This means:

* We can do a lot of cool stuff.
* Pinging IPv4 yields ARP table entries.
* Pinging IPv6 yields ICMPv6 Neighbor Solicitation.
* Multicast works out of the box.
* Across clouds, and through NAT devices.

## What lies ahead

This repository yields a lab environment for exploring ZeroTier.

- We shall ping
- We shall tcpdump
- We shall manipulate interfaces and bridges
- We shall do IPv6

No networking devices were harmed during the production of
this document.

## Technical Prerequisites

This Quickstart was written on an OSX laptop from a residential
ISP.

To follow along step by step, you will need accounts on public cloud
vendors. You will need git, a text editor, and a copy of Terraform
1.0.0 or later installed locally.

The full-blown multicloud demo uses:

- Digital Ocean
- Amazon Web Services
- Google Compute Engine
- Microsoft Azure
- Oracle Cloud Infrastructure
- Alibaba Cloud
- IBM Cloud
- Vultr
- Equinix Metal

That's a lot of service providers. You'll need at least two for
demonstration purposes, but I recommend using them all for dramatic
effect. Digital Ocean was chosen at random to provide DNS service for
the lab.

The first time through, you will encounter a few hurdles. Each cloud
vendor brings their own special brand of pain. For example, on AWS,
you will need to accept the Marketplace agreement for the Ubuntu
AMI. On GCP, you will be prompted to enable Cloud APIs. Others have
stringent account verification procedures.

<p align="center">
<img src="https://i.imgur.com/5tRu35i.jpeg" alt="old man yells at cloud" /><br/>
</p>

To lower the bar of entry, you can toggle which clouds are
enabled `variables.tf`. The process for creating service accounts and
gathering credentials is outside the scope of this document, but
should be pretty straight forward.

You can do this. We believe in you.

## A Quick Tour of the Terraform code

This repository is meant to teach you three things.

- How to manipulate ZeroTier Networks and Members with Terraform.
- How to bootstrap ZeroTier on your favorite cloud provider.
- How to use some of ZeroTier's more advanced capabilities.

Open [main.tf](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/main.tf)


At the top, you'll see Terraform resources for creating
[Identities](https://github.com/zerotier/terraform-provider-zerotier#identities),
[Networks](https://github.com/zerotier/terraform-provider-zerotier#networks),
and [Members](https://github.com/zerotier/terraform-provider-zerotier#members).

The synopsis is as follows:

```hcl
# zerotier networks

resource "zerotier_network" "hello" {
  # settings ...
}

resource "zerotier_identity" "instance" {}

resource "somecloud_instance" "instance" {
  # settings ...
  #
  # zerotier_identity.instance.public_key to disk
  # zerotier_identity.instance.private_key to disk
  # install zerotier
}

resource "zerotier_member" "instance" {
  network_id  = zerotier_network.hello.id
  member_id   = zerotier_identity.instance.id
}

```

And for physical devices such as phones, laptops, workstations, etc

```hcl
# non-ephemeral devices

resource "zerotier_member" "laptop" {
  network_id  = zerotier_network.hello.id
  member_id   = "laptop_id"
}

```


Below that, you'll see a module for each cloud. You'll notice
overlapping `192.168` CIDRs. This is on purpose, to simulate
residential ISPs and other networks outside our administrative
control.

The
[modules](https://github.com/zerotier/zerotier-terraform-quickstart/tree/main/modules)
do the bare minimum required to spin up an instance and
[inject](https://github.com/zerotier/zerotier-terraform-quickstart/blob/d04d0bd9ee69461e59666efccda9978a1767e076/modules/aws/main.tf#L140)
an identity into a boot script.

The [boot script](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/init-common.tpl)
writes the ZeroTier identity to disk and installs ZeroTier. It also
installs SSH keys and various utilities for our lab, such as ping and tshark.

## Configure the Quickstart repository

Check out the source code for the quickstart and change into the
directory.

```bash
laptop:~$ git clone git@github.com:zerotier/zerotier-terraform-quickstart.git
laptop:~$ cd zerotier-terraform-quickstart
laptop:~/zerotier-terraform-quickstart$ emacs variables.tf
```

### User account SSH keys

Next, add some SSH keys to the `users` variable. These will be passed to
[cloud-init](https://cloudinit.readthedocs.io/en/latest/) when
bootstrapping the instances. You'll need at least one for yourself,
but we recommending adding a friend.

```hcl
variable "users" {
  default = {
    alice = {
      username   = "alice"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxBkqXD41K8LfyJrjf8PSrxsNqhNUlWfqIzM52iWy+B alice@computers.biz"
    }
    bob = {
      username   = "bob"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPxC8oiMHeqcTH507iWJbHs/4/yx3vOOBDf/n6Eowj7 bob@computers.biz"
    }
  }
}
```

### Device identities

Next, add the ZeroTier identities of any non-ephemeral devices we plan
to connect to our lab network. If you haven't already, install the
ZeroTier client on your laptop or workstation. You can get it from the
[ZeroTier Downloads page](https://www.zerotier.com/download/).

```bash
laptop:~$ zerotier-cli info
200 info a11c3411ce 1.6.5 ONLINE
```

```hcl
variable "devices" {
  default = {
    laptop = {
      member_id   = "a11c3411ce"
      description = "Alice's laptop"
    }
    desktop = {
      member_id   = "b0bd0bb0bb"
      description = "Bob's laptop"
    }
  }
}
```

### Enable or Disable Clouds

Next, select which clouds to enable. You'll need at least two for
demonstration purposes, but I recommend using them all for dramatic
effect. Digital Ocean is required, since it will be providing DNS
service for the lab.

```hcl

  default = {
    do = {
      description   = "Digital Ocean"
      ip_assignment = "10.0.1.1"
      enabled       = true
    }
    aws = {
      description   = "Amazon Web Services"
      ip_assignment = "10.0.2.1"
      enabled       = true
    }
    gcp = {
      description   = "Google Compute Platform"
      ip_assignment = "10.0.3.1"
      enabled       = true
    }
    azu = {
      description   = "Microsoft Azure"
      ip_assignment = "10.0.4.1"
      enabled       = true
    }
    oci = {
      description   = "Oracle Cloud Infrastructure"
      ip_assignment = "10.0.5.1"
      enabled       = true
    }
    ibm = {
      description   = "IBM Cloud"
      ip_assignment = "10.0.6.1"
      enabled       = true
    }
    vul = {
      description   = "Vultr"
      ip_assignment = "10.0.7.1"
      enabled       = true
    }
    ali = {
      description   = "Alibaba Cloud"
      ip_assignment = "10.0.8.1"
      enabled       = true
    }
    eqx = {
      description   = "Equinix Metal"
      ip_assignment = "10.0.9.1"
      enabled       = true
    }
  }
}
```

## Provision a ZeroTier Central API Token

![Create a Network](https://i.imgur.com/3GDoBaF.png)

## Set Environment Variables

Please place the following in your ```~/.bash_profile```, then ```source ~/.bash_profile```

```bash

# ZeroTier Central
export ZEROTIER_CENTRAL_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export ZEROTIER_CENTRAL_URL="https://my.zerotier.com/api"

# Digital Ocean
export DIGITALOCEAN_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Amazon Web Services
export AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Google Compute Platform
export GOOGLE_CREDENTIALS="$(cat key-downloaded-from-gcp-console.json)"
export GOOGLE_CLOUD_PROJECT="XXX-XXXXXX"
export GOOGLE_REGION="us-east4"
export GOOGLE_ZONE="us-east4-a"

# Microsoft Azure
export ARM_SUBSCRIPTION_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
export ARM_TENANT_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
export ARM_CLIENT_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
export ARM_CLIENT_SECRET="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# IBM Cloud
export IBMCLOUD_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export IBMCLOUD_REGION="us-east"

# Oracle Cloud Infrastructure
export TF_VAR_compartment_id="ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# please configure ~/.oci/config

# Alibaba Cloud
export ALICLOUD_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXXX"
export ALICLOUD_SECRET_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export ALICLOUD_REGION="us-east-1"

# Vultr
export VULTR_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Equinix Metal
export METAL_AUTH_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

## Comment out unused clouds in `main.tf`

Due to the way Terraform's provider system works, you'll end up having
to comment out any unused clouds in [main.tf](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/main.tf)

Sorry.

``` hcl
# #
# # Oracle Cloud Infrastructure
# #

# variable "compartment_id" { default = "set_me_as_a_TF_VAR_" }

# module "oci" {
#   source         = "./modules/oci"
#   for_each       = { for k, v in var.instances : k => v if k == "oci" && v.enabled }
#   name           = "oci"
#   vpc_cidr       = "192.168.0.0/16"
#   subnet_cidr    = "192.168.1.0/24"
#   compartment_id = var.compartment_id
#   dnsdomain      = zerotier_network.demolab.name
#   zt_networks    = { demolab = { id = zerotier_network.demolab.id } }
#   zt_identity    = zerotier_identity.instances["oci"]
#   svc            = var.users
#   script         = "init-common.tpl"
# }
```

## Spin up the lab instances

<p align="center">
<img src="https://i.imgur.com/qglRkyw.jpeg" height="300" alt="Baton Bunny, Copyright 1959  Warner Bros." /><br/>
Baton Bunny - Warner Bros. 1959
</p>

```bash
terraform init -upgrade && terraform plan && terraform apply -auto-approve
```

```
Upgrading modules...
- ali in modules/ali
- aws in modules/aws
- azu in modules/azu
- do in modules/do
- eqx in modules/eqx
- gcp in modules/gcp
- ibm in modules/ibm
- oci in modules/oci
- vul in modules/vul

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/oci...
- Finding latest version of aliyun/alicloud...
- Finding latest version of vultr/vultr...
- Finding latest version of hashicorp/google...
- Finding latest version of zerotier/zerotier...
- Finding latest version of hashicorp/aws...
- Finding latest version of ibm-cloud/ibm...
- Finding latest version of equinix/metal...
- Finding latest version of hashicorp/tls...
- Finding latest version of digitalocean/digitalocean...
- Finding latest version of hashicorp/template...
- Finding latest version of hashicorp/azurerm...
- Installing hashicorp/aws v3.55.0...
- Installed hashicorp/aws v3.55.0 (signed by HashiCorp)
- Installing equinix/metal v3.1.0...
- Installed equinix/metal v3.1.0 (signed by a HashiCorp partner, key ID 1A65631C7288685E)
- Installing hashicorp/tls v3.1.0...
- Installed hashicorp/tls v3.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)
- Installing aliyun/alicloud v1.132.0...
- Installed aliyun/alicloud v1.132.0 (signed by a HashiCorp partner, key ID 47422B4AA9FA381B)
- Installing hashicorp/google v3.81.0...
- Installed hashicorp/google v3.81.0 (signed by HashiCorp)
- Installing zerotier/zerotier v1.0.2...
- Installed zerotier/zerotier v1.0.2 (signed by a HashiCorp partner, key ID FE5A2DBE1B75988C)
- Installing ibm-cloud/ibm v1.30.0...
- Installed ibm-cloud/ibm v1.30.0 (self-signed, key ID AAD3B791C49CC253)
- Installing digitalocean/digitalocean v2.11.1...
- Installed digitalocean/digitalocean v2.11.1 (signed by a HashiCorp partner, key ID F82037E524B9C0E8)
- Installing hashicorp/azurerm v2.73.0...
- Installed hashicorp/azurerm v2.73.0 (signed by HashiCorp)
- Installing hashicorp/oci v4.40.0...
- Installed hashicorp/oci v4.40.0 (signed by HashiCorp)
- Installing vultr/vultr v2.4.1...
- Installed vultr/vultr v2.4.1 (signed by a HashiCorp partner, key ID 853B1ED644084048)
<snip>
```

You will see a whole lot of text scoll by, ending with something that
looks like this.

```bash
<snip>
module.ali["ali"].alicloud_eip_association.this: Still creating... [30s elapsed]
module.azu["azu"].azurerm_linux_virtual_machine.this: Still creating... [20s elapsed]
module.ibm["ibm"].ibm_is_instance.this: Still creating... [30s elapsed]
module.eqx["eqx"].metal_device.this: Still creating... [1m20s elapsed]
module.ali["ali"].alicloud_eip_association.this: Creation complete after 39s [id=eip-0xid1dwiqzt7rjrzzmg8p:i-0xige8omj8sojsvhyqfc]
module.azu["azu"].azurerm_linux_virtual_machine.this: Still creating... [30s elapsed]
module.ibm["ibm"].ibm_is_instance.this: Still creating... [40s elapsed]
module.eqx["eqx"].metal_device.this: Still creating... [1m30s elapsed]
module.azu["azu"].azurerm_linux_virtual_machine.this: Still creating... [40s elapsed]
module.ibm["ibm"].ibm_is_instance.this: Still creating... [50s elapsed]
module.eqx["eqx"].metal_device.this: Still creating... [1m40s elapsed]
module.azu["azu"].azurerm_linux_virtual_machine.this: Still creating... [50s elapsed]
module.ibm["ibm"].ibm_is_instance.this: Still creating... [1m0s elapsed]
module.eqx["eqx"].metal_device.this: Still creating... [1m50s elapsed]
module.ibm["ibm"].ibm_is_instance.this: Creation complete after 1m1s [id=0757_e76365c7-217e-4ca5-a8ad-3dd7ec80af45]
module.azu["azu"].azurerm_linux_virtual_machine.this: Creation complete after 55s [id=/subscriptions/4d967f78-4005-4c96-9c28-c8965b2c6dfe/resourceGroups/azu/providers/Microsoft.Compute/virtualMachines/azu]
module.eqx["eqx"].metal_device.this: Still creating... [2m0s elapsed]
module.eqx["eqx"].metal_device.this: Still creating... [2m10s elapsed]
module.eqx["eqx"].metal_device.this: Still creating... [2m20s elapsed]
module.eqx["eqx"].metal_device.this: Still creating... [2m30s elapsed]
module.eqx["eqx"].metal_device.this: Creation complete after 2m40s [id=9eac4e4d-4a13-4d0a-b54f-268ce3bc9beb]

Apply complete! Resources: 89 added, 0 changed, 0 destroyed.

Outputs:

identities = {
  "ali" = "b0ae957168"
  "aws" = "6695d1fce6"
  "azu" = "b7ab6594a9"
  "do" = "37f2b7c94f"
  "eqx" = "cc5c1f20d1"
  "gcp" = "01d835fcf2"
  "ibm" = "ad6cb853aa"
  "oci" = "d5b230e028"
  "vul" = "1dcc6338ff"
}
networks = {
  "demolab" = "1c33c1ced07ac85d"
}
```

## Join Laptop to Lab Network

<p align="center">
<img src="https://i.imgur.com/iyC4zUT.png" alt="join network" /><br/>
</p>

## Behold the network in the Central UI

<p align="center">
<img src="https://i.imgur.com/i3OpSpF.png" alt="join network" /><br/>
</p>

## Hit the web servers

Each node is running a web server with an example nginx page,
accessible with an internal DNS address.

For example,  [http://aws.demo.lab](http://aws.demo.lab/).

<p align="center">
<img src="https://i.imgur.com/UHe6UXq.png" alt="join network" /><br/>
</p>

# Understanding ZeroTier VL2

ZeroTier networks are virtual Ethernet switches. This means that
anything you can do on a physical LAN segment, ZeroTier can over the
Internet, securely, across clouds, and through NAT devices.

<p align="center">
<img src="https://live.staticflickr.com/106/311526846_24b03feedf_w_d.jpg" alt="https://www.flickr.com/photos/valkyrieh116/311526846" /><br/>
Down the Rabbit Hole - Valerie Hinojosa 2006
</p>

```bash
laptop:~$ ssh do.demo.lab
```

## Ping all the boxen (v4)

```bash
alice@do:~$ for i in laptop aws gcp azu oci ali ibm vul eqx ; do ping -4 -c 1 $i.demo.lab ; done &>/dev/null
```

## Examine the ARP cache

```bash
alice@do:~$ arp -a | grep demo | sort
ali.demo.lab (10.0.8.1) at 5e:1e:72:fb:14:e4 [ether] on zt2lr3wbun
aws.demo.lab (10.0.2.1) at 5e:6c:4b:3a:05:4f [ether] on zt2lr3wbun
azu.demo.lab (10.0.4.1) at 5e:d5:43:77:15:62 [ether] on zt2lr3wbun
eqx.demo.lab (10.0.9.1) at 5e:11:0c:5d:cd:44 [ether] on zt2lr3wbun
gcp.demo.lab (10.0.3.1) at 5e:5f:43:6c:9a:58 [ether] on zt2lr3wbun
ibm.demo.lab (10.0.6.1) at 5e:38:83:97:55:1a [ether] on zt2lr3wbun
laptop.demo.lab (10.0.0.83) at 5e:27:8a:8d:21:51 [ether] on zt2lr3wbun
oci.demo.lab (10.0.5.1) at 5e:19:d5:76:be:24 [ether] on zt2lr3wbun
vul.demo.lab (10.0.7.1) at 5e:3c:36:a8:9f:9d [ether] on zt2lr3wbun
```

As you can see, the ARP table now contains an entry for each node on
our network, just as it would on a local ethernet network.

## Examine the interfaces

Run the `ip link` command to examine the interfaces on each box.

```bash
alice@do:~$ ip link | grep -A1 zt
4: zt2lr3wbun: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2800 qdisc fq_codel state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 5e:56:14:d3:25:ed brd ff:ff:ff:ff:ff:ff
```

You'll see a virtual ethernet interface for each ZeroTier network the node is joined to. (in this case, one)

```bash
alice@aws:~$ ip link | grep  -A1 zt
3: zt2lr3wbun: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2800 qdisc fq_codel state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 5e:6c:4b:3a:05:4f brd ff:ff:ff:ff:ff:ff
```

The name of the interface is derived from the network ID it is joined
to. Notice that the name of the interface is the same on each machine.

```bash
alice@oci:~$ ip link | grep -A1 zt
3: zt2lr3wbun: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2800 qdisc fq_codel state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 5e:19:d5:76:be:24 brd ff:ff:ff:ff:ff:ff
```

## Ethernet Tapping

You may have noticed the [flow_rules](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/flow_rules.tpl)
section in the `zerotier_network` while examining [main.tf](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/main.tf)
earlier.

```hcl
resource "zerotier_network" "demolab" {
  name        = "demo.lab"
  description = "ZeroTier Terraform Demolab"
  assign_ipv6 {
    zerotier = true
    sixplane = false
    rfc4193  = true
  }
  assignment_pool {
    start = "10.0.0.1"
    end   = "10.0.0.254"
  }
  route {
    target = "10.0.0.0/16"
  }
  flow_rules = templatefile("${path.module}/flow_rules.tpl", {
    ethertap = zerotier_identity.instances["do"].id
  })
}
```

We will use these to gain visibility into our network with tshark. You
can see them reflected in the Central WebUI under the "Flow Rules"
section for the `demo.lab` network. They are documented in in-depth in
chapter 3 of the [ZeroTier Manual](https://www.zerotier.com/manual/#3).

Edit `flow_rules.tpl`, uncommenting the `tee` rule.

```
# drop not ethertype ipv4 and not ethertype arp and not ethertype ipv6;
tee -1 ${ethertap};
# watch -1 ${ethertap} chr inbound;
accept;
```

Flow Rules are applied to every member of the network. `tee` tells
ZeroTier to mirror a copy of every packet to Digital Ocean. Apply the
rule set by saving the file and running Terraform.

```bash
terraform apply -target 'zerotier_network.demolab' -auto-approve
```

## Watching traffic with tshark

On the Digital Ocean machine, view the traffice by running tshark on
your network's ZeroTier interface.

```
sudo tshark -i zt2lr3wbun not port ssh
```

Open another terminal window, log into AWS, and ping GCP.

```
alice@aws:~$ ping -4 -c 1 gcp.demo.lab
PING gcp.demo.lab (10.0.3.1) 56(84) bytes of data.
64 bytes from gcp.demo.lab (10.0.3.1): icmp_seq=1 ttl=64 time=2.02 ms

--- gcp.demo.lab ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2.016/2.016/2.016/0.000 ms
```

You will be able to observe the traffic from Digital Ocean.

```
<snip>
37 67.550026693     10.0.2.1 → 10.0.3.1     ICMP 98 Echo (ping) request  id=0x0005, seq=1/256, ttl=64
38 67.551676229     10.0.2.1 → 10.0.3.1     ICMP 98 Echo (ping) request  id=0x0005, seq=1/256, ttl=64
39 67.551728848     10.0.3.1 → 10.0.2.1     ICMP 98 Echo (ping) reply    id=0x0005, seq=1/256, ttl=64 (request in 38)
40 67.551933296     10.0.3.1 → 10.0.2.1     ICMP 98 Echo (ping) reply    id=0x0005, seq=1/256, ttl=64
<snip>
```

You'll notice duplicates, as the `tee` is picking up both the incoming
and outgoing packets from both nodes.

Edit `flow_rules.tpl`, this time using the `watch` rule.

```
# drop not ethertype ipv4 and not ethertype arp and not ethertype ipv6;
# tee -1 ${ethertap};
watch -1 ${ethertap} chr inbound;
accept;
```

Apply the rule set with Terraform

```bash
terraform apply -target 'zerotier_network.demolab' -auto-approve
```

You can also see the the traffic from your laptop when hitting the web
servers. Load the page on IBM Cloud by visiting http://ibm.demo.lab, and
observe the traffic in your Digital Ocean terminal.

```
<snip>
327 199.676637284    10.0.0.83 → 10.0.9.1     TCP 78 51690 → 80 [SYN, ECN, CWR] Seq=0 Win=65535 Len=0 MSS=1460 WS=64 TSval=1436274934 TSecr=0 SACK_PERM=1
328 199.676674544    10.0.0.83 → 10.0.9.1     TCP 78 51691 → 80 [SYN, ECN, CWR] Seq=0 Win=65535 Len=0 MSS=1460 WS=64 TSval=3175387241 TSecr=0 SACK_PERM=1
329 199.794743954     10.0.9.1 → 10.0.0.83    TCP 74 80 → 51690 [SYN, ACK, ECN] Seq=0 Ack=1 Win=41220 Len=0 MSS=2760 SACK_PERM=1 TSval=2662049172 TSecr=1436274934 WS=256
330 199.794958371     10.0.9.1 → 10.0.0.83    TCP 74 80 → 51691 [SYN, ACK, ECN] Seq=0 Ack=1 Win=41220 Len=0 MSS=2760 SACK_PERM=1 TSval=2662049172 TSecr=3175387241 WS=256
331 199.803150936    10.0.0.83 → 10.0.9.1     TCP 66 51690 → 80 [ACK] Seq=1 Ack=1 Win=131712 Len=0 TSval=1436275068 TSecr=2662049172
332 199.803187906    10.0.0.83 → 10.0.9.1     TCP 66 51691 → 80 [ACK] Seq=1 Ack=1 Win=131712 Len=0 TSval=3175387373 TSecr=2662049172
333 199.803196207    10.0.0.83 → 10.0.9.1     HTTP 542 GET / HTTP/1.1
334 199.922328374     10.0.9.1 → 10.0.0.83    TCP 66 80 → 51690 [ACK] Seq=1 Ack=477 Win=40960 Len=0 TSval=2662049299 TSecr=1436275068
335 199.923128703     10.0.9.1 → 10.0.0.83    TCP 292 HTTP/1.1 200 OK  [TCP segment of a reassembled PDU]
336 199.924188988     10.0.9.1 → 10.0.0.83    TCP 1514 HTTP/1.1 200 OK  [TCP segment of a reassembled PDU]
337 199.927168487     10.0.9.1 → 10.0.0.83    HTTP 1514 [TCP Previous segment not captured] Continuation
338 199.928171943     10.0.9.1 → 10.0.0.83    TCP 1514 80 → 51690 [PSH, ACK] Seq=4571 Ack=477 Win=40960 Len=1448 TSval=2662049300 TSecr=1436275068 [TCP segment of a reassembled PDU]
339 199.928634956    10.0.0.83 → 10.0.9.1     TCP 66 51690 → 80 [ACK] Seq=477 Ack=227 Win=131520 Len=0 TSval=1436275194 TSecr=2662049300
340 199.928824523    10.0.0.83 → 10.0.9.1     TCP 66 51690 → 80 [ACK] Seq=477 Ack=1675 Win=130048 Len=0 TSval=1436275194 TSecr=2662049300
<snip>
```

