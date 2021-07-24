# Multiple Networks with overlaps

You can have multiple IP networks on a single ZeroTier network
Multiple ZeroTier networks can have overlapping IP space.

## Usage

To run this example you need to:

First, log into [my.zerotier.com](https://my.zerotier.com) and create an API
token under the [Account](https://my.zerotier.com/account) section.

Next, export the `ZEROTIER_CENTRAL_TOKEN` variable in your shell or
Terraform workspace.

```
terraform init
terraform plan
terraform apply
```
