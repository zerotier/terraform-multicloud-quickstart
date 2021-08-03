
variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "source_dest_check" {
  type = bool
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "user_data" {
  sensitive = true
}

variable "vpc_security_group_ids" {
  type = list(string)
}

resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  source_dest_check      = var.source_dest_check
  subnet_id              = var.subnet_id
  tags                   = var.tags
  user_data              = var.user_data
  vpc_security_group_ids = var.vpc_security_group_ids
}

output "id" {
  value = aws_instance.this.id
}
