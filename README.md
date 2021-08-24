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
do the bare required to spin up an instance and
[inject](https://github.com/zerotier/zerotier-terraform-quickstart/blob/d04d0bd9ee69461e59666efccda9978a1767e076/modules/aws/main.tf#L140)
an identity into a boot script.

The [boot script](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/init-common.tpl)
writes the ZeroTier identity to disk and installs ZeroTier. It also
installs SSH users and various utilities for our lab, such as ping and
tshark.

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
    alice = {
      member_id   = "a11c3411ce"
      description = "Alice's laptop"
    }
    bob = {
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
      enabled       = true
    }
    gcp = {
      description   = "Google Compute Platform"
      ip_assignment = "10.4.2.3"
      enabled       = true
    }
    azu = {
      description   = "Microsoft Azure"
      ip_assignment = "10.4.2.4"
      enabled       = true
    }
    oci = {
      description   = "Oracle Cloud Infrastructure"
      ip_assignment = "10.4.2.5"
      enabled       = true
    }
    ibm = {
      description   = "IBM Cloud"
      ip_assignment = "10.4.2.6"
      enabled       = true
    }
    vul = {
      description   = "Vultr"
      ip_assignment = "10.4.2.8"
      enabled       = true
    }
    ali = {
      description   = "Alibaba Cloud"
      ip_assignment = "10.4.2.7"
      enabled       = true
    }
    eqx = {
      description   = "Equinix Metal"
      ip_assignment = "10.4.2.9"
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
to comment out any unused clouds in [main.tf](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/main.tf)`

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
</p>

```bash
laptop:~/zerotier-terraform-quickstart$ terraform init -upgrade
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

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
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
  "ali" = "4a1eb0ab38"
  "aws" = "3d53f4fca4"
  "azu" = "ab209b77f6"
  "do" = "c15c9c3bcb"
  "eqx" = "1db2600c70"
  "gcp" = "7701c7718e"
  "ibm" = "c093a8bfec"
  "oci" = "157ea56cec"
  "vul" = "697b5ed34b"
}
networks = {
  "demolab" = "6ab565387aa5001d"
}
```

## Join Laptop to Lab Network

```bash
laptop:~$ zerotier-cli join <networkid>
laptop:~$ zerotier-cli  set <networkid> allowDNS=1
```

## Log into and take a look around

```bash
laptop:~$ ssh alice@do.demo.lab
```

## Ping all the boxen

```bash
laptop:~$ ping -4 -c 2 do.demo.lab
laptop:~$ ping -4 -c 2 aws.demo.lab
laptop:~$ ping -4 -c 2 gcp.demo.lab
laptop:~$ ping -4 -c 2 azu.demo.lab
laptop:~$ ping -4 -c 2 oci.demo.lab
laptop:~$ ping -4 -c 2 ibm.demo.lab
laptop:~$ ping -4 -c 2 vul.demo.lab
laptop:~$ ping -4 -c 2 ali.demo.lab
```
