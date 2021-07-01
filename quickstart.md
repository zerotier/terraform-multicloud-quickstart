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

## What lies ahead

This repository yields a lab environment for exploring ZeroTier.

- We shall ping
- We shall tcpdump
- We shall manipulate interfaces and bridges
- We shall do IPv6

No networking devices were harmed during the production of
this document.

## The plan

## Technical Prerequisites

This quickstart requires the following environmental variables

```
AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXXXXXXXX"
AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

ARM_SUBSCRIPTION_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
ARM_TENANT_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
ARM_CLIENT_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
ARM_CLIENT_SECRET="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

GOOGLE_CREDENTIALS="$(cat key-downloaded-from-gcp-console.json)"

ZEROTIER_CENTRAL_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```
