# ZeroTier Terraform Quickstart

<p align="center">
<img src="https://avatars.githubusercontent.com/u/4173285?s=200&v=4" alt="ZeroNSD" style="width:100%;"><br>
<b><i>
We are living in an ephemeral world<br>
I am an ephemeral girl<br>
</i></b>
</p>

## Status

* This is beta software
* If we get enough positive feedback, we shall christen a 1.0.0
* Here be Dragons (maybe)

## Conceptual Prerequisites

* ZeroTier Networks are objects in the Central API
* ZeroTier Identities are the public crypto identities installed in nodes; machines, containers, or binaries
* ZeroTier Members are associations between Networks and Identities
* ZeroTier virtualizes an L2 network (ethernet)

This means:

* We can do lots of cool stuff.
* Pinging IPv4 addresses will yield arp table entries
* Pinging IPv6 addresses yield ICMPv6 Neighbor Solicitation
* Across clouds and from behind NAT devices

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
