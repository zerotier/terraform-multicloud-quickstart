
# resource "aws_vpc" "this" {
#   cidr_block                       = "10.1.0.0/16"
#   enable_dns_support               = false
#   enable_dns_hostnames             = false
#   assign_generated_ipv6_cidr_block = false
#   tags                             = { "Name" = "qs-aws-fra" }
# }

# resource "aws_subnet" "this" {
#   availability_zone               = "eu-central-1a"
#   cidr_block                      = "10.1.1.0/24"
#   assign_ipv6_address_on_creation = false
#   vpc_id                          = aws_vpc.this.id
#   tags                            = { "Name" = "qs-aws-fra-zone-00" }
# }

# resource "aws_internet_gateway" "this" {
#   vpc_id = aws_vpc.this.id
#   tags   = { "Name" = "qs-aws-fra" }
# }

# resource "aws_route_table" "this" {
#   vpc_id = aws_vpc.this.id
#   tags   = { "Name" = "qs-aws-fra" }
# }

# resource "aws_route_table_association" "this" {
#   subnet_id      = aws_subnet.this.id
#   route_table_id = aws_route_table.this.id
# }

# resource "aws_route" "the_internet" {
#   route_table_id         = aws_route_table.this.id
#   gateway_id             = aws_internet_gateway.this.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_network_acl" "this" {
#   vpc_id = aws_vpc.this.id
#   tags   = { "Name" = "qs-aws-fra" }
# }

# resource "aws_network_acl_rule" "this" {
#   network_acl_id = aws_network_acl.this.id
#   cidr_block     = "0.0.0.0/0"
#   rule_number    = 100
#   protocol       = "-1"
#   from_port      = 0
#   to_port        = 0
#   rule_action    = "allow"
# }

# resource "aws_security_group" "this" {
#   vpc_id      = aws_vpc.this.id
#   name        = "allow_all"
#   description = "allow_all"

#   ingress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = { "Name" = "allow_all" }
# }


# data "aws_ami" "this" {
#   owners      = ["099720109477"]
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

# }

# resource "aws_instance" "this" {
#   ami               = data.aws_ami.this.id
#   instance_type     = "t3.micro"
#   source_dest_check = false
#   subnet_id         = aws_subnet.this.id
#   tags              = { "Name" = "qs-aws-fra" }
#   #  user_data_base64                     = ""
# }
