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
* ZeroTier Identities are the public keys of nodes; machines, containers, or binaries.
* ZeroTier Members are associations between Networks and Identities.
* ZeroTier virtualizes at L1 and L2 (ethernet).

This means:

* We can do a lot of cool stuff.
* Pinging IPv4 yields ARP table entries.
* Pinging IPv6 yields ICMPv6 Neighbor Solicitation.
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

Terraform will create a ZeroTier network, then bootstrap instances on
various clouds. To follow along, you'll need service accounts on
Digical Ocean, and at least two other clouds.

The full blown multicloud demo uses

- Digital Ocean
- Amazon Web Services
- Google Compute Engine
- Microsoft Azure
- Oracle Cloud Infrastructure
- Alibaba Cloud
- IBM Cloud
- Vultr
- Equinix Metal

That's a lot of services providers. You'll need at least two for
demonstration purposes, but I recommend using them all for dramatic
effect. Digital Ocean was chosen at random to provide DNS service for
the lab.

The first time through, you will encounter a few hurdles. Each cloud
vendor brings their own special brand of pain. For example, on AWS,
you will need to accept the Marketplace agreement for the Ubuntu
AMI. On GCP, you will be prompted to enable Cloud APIs.

<p align="center">
<img src="https://i.imgur.com/5tRu35i.jpeg" alt="old man yells at cloud" /><br/>
</p>

To lower the bar of entry, you can toggle which cloud vendors are
enabled in the config section. The process for creating service
accounts is outside the scope of this document, but should be pretty
straight forward. You can do this. We believe in you.

## A Quick Tour of the Terraform code

This repository is meant to teach you three things.

- How to manipulate ZeroTier Networks and Members with Terraform.
- How to bootstrap ZeroTier on your favorite cloud provider.
- How to use some of ZeroTier's more advanced capabilities.

Open [main.tf](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/main.tf)

At the top, you'll see Terraform resourcesfor creating
[Identities](https://github.com/zerotier/terraform-provider-zerotier#identities),
[Networks](https://github.com/zerotier/terraform-provider-zerotier#networks),
and [Members](https://github.com/zerotier/terraform-provider-zerotier#members).

The [modules](https://github.com/zerotier/zerotier-terraform-quickstart/blob/main/main.tf)
directory contains Just Enough Terraform to spin up an instance on
each cloud, and [inject](https://github.com/zerotier/zerotier-terraform-quickstart/blob/d04d0bd9ee69461e59666efccda9978a1767e076/modules/aws/main.tf#L140)
an identity into a boot script through `cloud-init`.



## Configure the Quickstart repository

Check out the source code for the quickstart and cd into the
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

Next, we will add the ZeroTier identities of the non-ephemeral devices
we plan to connect to our lab network. If you haven't already, install
the ZeroTier client on your laptop or workstation. You can get it from
the [ZeroTier Downloads page](https://www.zerotier.com/download/).

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

Please place the following in your ```~/.bash_profile```, then run ```source ~/.bash_profile```

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

## Comment unused clouds in main.tf

Due to the way Terraform's provider system works, you'll end up having
to comment out any unused clouds in main.tf.

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

```bash
laptop:~/zerotier-terraform-quickstart$ terraform init && terraform plan && terraform apply
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
