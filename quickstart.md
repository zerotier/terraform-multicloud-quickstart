# ZeroTier Terraform Quickstart

<p align="center">
<img src="https://avatars.githubusercontent.com/u/4173285?s=200&v=4" alt="ZeroNSD" style="width:100%;"><br>
<b><i>
We are Living in an Ephemeral World<br>
I am an Ephemeral Girl<br>
</i></b>
</p>

## Status

* This is beta software
* If we get enough positive feedback, we shall christen a 1.0.0
* Here be Dragons (maybe)

## Conceptual Prerequisites

* ZeroTier Networks are JSON objects in the Central API
* ZeroTier Identities are the public half of a crypto key pair
* ZeroTier Members a are associations between Networks and Identities
* ZeroTier emulates an L2 network (ethernet)

This means:

* Pinging IPv4 addresses will yield arp table entries
* Pinging IPv6 addresses 

## Technical Prerequisites

This Quickstart was written using two machines - one Ubuntu virtual
machine on Digital Ocean, and one OSX laptop on a residential ISP. To
follow along step by step, you'll need to provision equivalent
infrastructure. If you use different platforms, you should be able to
figure out what to do with minimal effort.

## Create a ZeroTier Network

You may do this manually through the [ZeroTier Central WebUI](https://my.zerotier.com),

![Create a Network](https://i.imgur.com/L6xtGKo.png)

## Install ZeroTier
