# ZeroTier Terraform Quickstart

## WORK IN PROGRESS

<p align="center">
<img src="https://avatars.githubusercontent.com/u/4173285?s=150&v=4" alt="ZeroNSD" /><br/>
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

## The plan

The general plan is simple. We shall use Terraform to create a
ZeroTier network, then spin up and bootstrap single virtiual machines
on each of Digital Ocean, Amazon Web Services, Google Compute
Platoform, and Microsoft Azure. We shall then log into them and
explore the "layer2eyness".

## Technical Prerequisites

This tutorial requires the driver to have accounts on each of the
major public cloud vendors.

## ZeroTier token

![Create a Network](https://i.imgur.com/3GDoBaF.png)

## Configure Environmet Variables

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

## Clone and configure quickstart repository

Check out the source

```
git clone git@github.com:zerotier/zerotier-terraform-quickstart.git
cd zerotier-terraform-quickstart
```

Configure the repository

```
emacs variables.tf
```

SSH keys

```
variable "svc" {
  default = {
    someara = {
      username   = "someara"
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINv7jD5KZu6lEVbHvzS+w+eQeuZGfY3jBaW7y5qftF1u sean@sean.io"
    }
  }
}
```

Clouds enabled
```
variable "enabled" {
  default = {
    do  = true
    aws = true
    gcp = true
    azu = true
  }
}
```

Laptop identity

```
variable "people" {
  default = {
    someara = {
      member_id   = "eff05def90"
      description = "Sean OMeara"
    }
  }
}
```

## Spin up the lab

```
terraform init && terraform plan && terraform apply -auto-approve
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
