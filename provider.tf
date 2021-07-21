
provider "aws" {
  region = "us-east-2"
}

provider "google" {
  region  = "us-central13"
  project = "lab1-8af32caf"
}

provider "azurerm" {
  features {}
}
