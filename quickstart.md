# ZeroTier Terraform Quickstart

<p align="center">
<img src="https://avatars.githubusercontent.com/u/4173285?s=200&v=4" alt="ZeroNSD" style="width:100%;"><br>
<b><i>
We are living in an ephemeral world<br>
I am an ephemeral girl<br>
</i></b>
</p>

## Status

* This is beta software.
* If we get enough positive feedback, we shall christen a 1.0.0.
* Here be Dragons (maybe).

## Conceptual Prerequisites

* ZeroTier Networks are objects in the Central API.
* ZeroTier Identities are public crypto identities installed in nodes; machines, containers, or binaries.
* ZeroTier Members are associations between Networks and Identities.
* ZeroTier virtualizes at L2 (ethernet).

This means:

* We can do a lot of cool stuff.
* Pinging IPv4 addresses will yield ARP table entries.
* Pinging IPv6 addresses yields ICMPv6 Neighbor Solicitation.
* Across clouds, and from behind NAT devices.

## Technical Prerequisites

This quickstart requires 4 environmental variables

AWS_

## Create a ZeroTier Network

You may do this manually through the [ZeroTier Central WebUI](https://my.zerotier.com),

![Create a Network](https://i.imgur.com/L6xtGKo.png)

## Install ZeroTier
