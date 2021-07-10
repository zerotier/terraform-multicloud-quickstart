
variable "private_ip_address_version" {
  type    = string
  default = "IPv4"
}

variable "private_ip_address_allocation" {
  type    = string
  default = "Dynamic"
}

variable "public_ip_address_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "size" {
  type = string
}

variable "admin_username" {
  type    = string
  default = null
}

variable "os_disk_caching" {
  type    = string
  default = null
}

variable "os_disk_storage_account_type" {
  type    = string
  default = null
}

variable "source_image_reference_publisher" {
  type    = string
  default = null
}

variable "source_image_reference_offer" {
  type    = string
  default = null
}

variable "source_image_reference_sku" {
  type    = string
  default = null
}

variable "source_image_reference_version" {
  default = null
}

variable "custom_data" {
  default = null
}
