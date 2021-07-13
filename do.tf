
resource "digitalocean_vpc" "example" {
  name     = "quickstart"
  region   = "fra1"
  ip_range = "10.1.0.0/16"
}

resource "digitalocean_droplet" "this" {
  image    = "ubuntu-20-04-x64"
  size     = "s-1vcpu-1gb"
  name     = "qs-do-fra"
  region   = "fra1"
  vpc_uuid = digitalocean_vpc.example.id
  tags     = []
  #  user_data = ""
}
