resource "aws_instance" "this" {
  ami                                  = var.ami
  associate_public_ip_address          = var.associate_public_ip_address
  cpu_core_count                       = var.cpu_core_count
  cpu_threads_per_core                 = var.cpu_threads_per_core
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  get_password_data                    = var.get_password_data
  hibernation                          = var.hibernation
  host_id                              = var.host_id
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  ipv6_address_count                   = var.ipv6_address_count
  ipv6_addresses                       = var.ipv6_addresses
  key_name                             = var.key_name
  monitoring                           = var.monitoring
  placement_group                      = var.placement_group
  private_ip                           = var.private_ip
  secondary_private_ips                = var.secondary_private_ips
  security_groups                      = var.security_groups
  source_dest_check                    = var.source_dest_check
  subnet_id                            = var.subnet_id
  tags                                 = var.tags
  tenancy                              = var.tenancy
  user_data                            = var.user_data
  user_data_base64                     = var.user_data_base64
  volume_tags                          = var.volume_tags
  vpc_security_group_ids               = var.vpc_security_group_ids
  # network_interface {}
  # metadata_options {}
  # ephemeral_block_device {}
  # enclave_options {}
  # ebs_block_device {}
  # credit_specification {}
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    encrypted  = var.root_block_device_encrypted
    kms_key_id = var.root_block_device_kms_key_id
  }
}
