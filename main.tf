
module "aws_vpc" {
  source               = "./modules/terraform-aws-vpc"
  instance_tenancy     = "default"
  enable_dns_hostnames = false
  enable_dns_support   = false
  cidr_block           = "10.1.0.0/16"
  tags                 = { "Name" = "qs-aws-fra" }
}

module "aws_subnet" {
  source                          = "./modules/terraform-aws-subnet"
  vpc_id                          = module.aws_vpc.id
  cidr_block                      = "10.1.1.0/24"
  availability_zone               = "eu-central-1a"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = { "Name" = "qs-aws-fra-zone-00" }
}

module "aws_internet_gateway" {
  source = "./modules/terraform-aws-internet_gateway"
  vpc_id = module.aws_vpc.id
  tags   = { "Name" = "qs-aws-fra" }
}

module "aws_route_table" {
  source = "./modules/terraform-aws-route_table"
  vpc_id = module.aws_vpc.id
  tags   = { "Name" = "qs-aws-fra" }
}

module "aws_route_table_association" {
  source         = "./modules/terraform-aws-route_table_association"
  subnet_id      = module.aws_subnet.id
  route_table_id = module.aws_route_table.id
}

module "aws_route_the_internet" {
  source                 = "./modules/terraform-aws-route"
  route_table_id         = module.aws_route_table.id
  gateway_id             = module.aws_internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

module "aws_network_acl" {
  source = "./modules/terraform-aws-network_acl"
  vpc_id = module.aws_vpc.id
  tags   = { "Name" = "qs-aws-fra" }
}

module "aws_network_acl_rule" {
  source         = "./modules/terraform-aws-network_acl_rule"
  network_acl_id = module.aws_network_acl.id
  cidr_block     = "0.0.0.0/0"
  rule_number    = 100
  protocol       = "-1"
  from_port      = 0
  to_port        = 0
  rule_action    = "allow"
}

module "aws_security_group" {
  source = "./modules/terraform-aws-security_group"
  vpc_id = module.aws_vpc.id
}

data "aws_ami" "this" {
  owners      = [ "099720109477" ]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

module "instance" {
  source                               = "./modules/terraform-aws-instance"
  ami                                  = data.aws_ami.this.id
  instance_type                        = "t3.micro"
  source_dest_check                    = false
  subnet_id                            = module.aws_subnet.id
  tags                                 = { "Name" = "qs-aws-fra" }
#  user_data_base64                     = ""
}
