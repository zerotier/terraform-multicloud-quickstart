provider "aws" {
  region = "eu-central-1"
}

provider "azurerm" {
  features {}
}

provider "google" {
  region  = "us-central13"
  project = "lab1-8af32caf"
}
