resource "digitalocean_droplet" "this" {
  image = "ubuntu-20-04-x64"
  name = "qs-do-fra"
  region = "fra1"
  size = "s-1vcpu-1gb"
  private_networking = true
}

output "digitalocean_droplet" {
  value = digitalocean_droplet.this
}
