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
* ZeroTier virtualizes at L2 (ethernet).

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

To follow along step by step, you will need to create service accounts
on Digital Ocean, and at least one other cloud vendor. You will need
git, a text editor, and a copy of Terraform 1.0.0 or later installed
locally.

Terraform will create a ZeroTier network, then bootstrap a single
instance on each of Digital Ocean, Amazon Web Services, Google Compute
Platform, and Microsoft Azure.

## Configure the Quickstart repository

Check out the source code for the quickstart and cd into the
directory.

```bash
laptop~$ git clone git@github.com:zerotier/zerotier-terraform-quickstart.git
laptop~$ cd zerotier-terraform-quickstart
laptop~$ emacs variables.tf
```

### Enable Clouds

Next, select which clouds to enable. You'll need at least two for
demonstration purposes, but I recommend using them all for dramatic
effect. Digital Ocean is required, since it will be providing DNS
service for the lab.

```hcl
variable "enabled" {
  default = {
    do  = true  #-- required (provides DNS)
    aws = true
    gcp = true
    azu = true
  }
}
```

### Service account SSH keys

Next, add some SSH keys to the `svc` variable. These will be passed to
[cloud-init](https://cloudinit.readthedocs.io/en/latest/) when
bootstrapping the instances. You'll need at least one, but we
recommending adding a friend.

```hcl
variable "svc" {
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

### Laptop identity

If you haven't already, install the ZeroTier client on your laptop or
workstation. You can get it from the [ZeroTier Downloads page](https://www.zerotier.com/download/).

```bash
laptop~$ zerotier-cli info
200 info eff05def90 1.6.5 ONLINE
```

```hcl
variable "devices" {
  default = {
    someara = {
      member_id   = "eff05def90"
      description = "Sean OMeara"
    }
  }
}
```

## Provision a ZeroTier Central API Token

![Create a Network](https://i.imgur.com/3GDoBaF.png)

## Set Environment Variables

Please place the following in your ```~/.bash_profile```, then run ```source ~/.bash_profile```

```
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

# Microsoft Azure
export ARM_SUBSCRIPTION_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
export ARM_TENANT_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
export ARM_CLIENT_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
export ARM_CLIENT_SECRET="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

## Spin up the lab

```
terraform init && terraform plan && terraform apply
```

## Join Laptop to Lab Network

```
zerotier-cli join <networkid> allowDNS=1
```

## Log into and take a look around

```
ssh do.demo.lab
ssh aws.demo.lab
ssh gcp.demo.lab
ssh azu.demo.lab
```
