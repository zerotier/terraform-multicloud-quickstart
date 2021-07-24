# Setting Routes

You can push routes and DNS server information from the Server API.
Please note that nodes can choose to ignore this information

A node running the ZeroTier agent will need to run
```
zerotier-cli set <networkId> allowDefault=1
```

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
