# ZeroTier Terraform Quickstart

<p align="center">
<img src="https://avatars.githubusercontent.com/u/4173285?s=200&v=4" alt="ZeroNSD" style="width:100%;"><br>
<b><i>
We are living in an ephemeral world<br>
And I am an ephemeral girl<br>
</i></b>
</p>

## Status

* This is beta software.
* If we get enough positive feedback, we shall christen a 1.0.0.
* Here be Dragons (maybe).

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

## Where we're going

This repository yields a lab environment for networking party tricks.  

We shall ping.  
We shall tcpdump.   
We shall do the IPv6.  

No networking devices were harmed during the production of
this document.  

## Technical Prerequisites

This quickstart requires 4 environmental variables

AWS_
