terraform {
  required_providers {
    zerotier = {
      source = "zerotier/zerotier"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    aws = {
      source = "hashicorp/aws"
    }
    google = {
      source = "hashicorp/google"
    }
    # azurerm = {
    #   source = "hashicorp/azurerm"
    # }
  }
}

# provider "aws" {
#   region = "eu-central-1"
# }

# provider "azurerm" {
#   features {}
# }

# provider "google" {
#   region  = "us-central13"
#   project = "lab1-8af32caf"
# }

# provider "digitalocean" {}
