# ZeroTier Terraform Quickstart

<p align="center">
<img src="https://avatars.githubusercontent.com/u/4173285?s=200&v=4" alt="ZeroNSD" style="width:100%;"><br>
<b><i>
I'm just an ephemeral girl<br>
Living in an ephemeral world<br>
</i></b>
</p>

## Status

* This is beta alpha software
* If we get enough positive feedback, we shall christen a 1.0
* Here be Dragons (maybe)

## Conceptual Prerequisites

* When ZeroTier joins a network, it creates a virtual network interface.
* When ZeroTier joins mutiple networks, there will be multiple network interfaces.
* When ZeroNSD starts, it binds to a ZeroTier network interface.
* When ZeroTier is joined to multiple networks, it needs multiple ZeroNSDs, one for each interface.

This means:

* ZeroNSD will be accessible from the node it is running on.
* ZeroNSD will be accessible from other nodes on the ZeroTier network.
* ZeroNSD will be isolated from other networks the node might be on.

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
