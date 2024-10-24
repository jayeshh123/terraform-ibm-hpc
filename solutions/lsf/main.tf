module "lsf" {
  source                     = "./../.."
  scheduler                  = "LSF"
  ibm_customer_number        = var.ibm_customer_number
  ibmcloud_api_key           = var.ibmcloud_api_key
  zones                      = var.zones
  allowed_cidr               = var.allowed_cidr
  prefix                     = local.env.prefix
  resource_group             = local.env.resource_group


  bootstrap_instance_profile = local.env.bootstrap_instance_profile
  bastion_ssh_keys           = local.env.bastion_ssh_keys
  bastion_subnets_cidr       = local.env.bastion_subnets_cidr
  compute_gui_password       = local.env.compute_gui_password
  compute_gui_username       = local.env.compute_gui_username
  compute_image_name         = local.env.compute_image_name
  compute_ssh_keys           = local.env.compute_ssh_keys
  compute_subnets_cidr       = local.env.compute_subnets_cidr
  cos_instance_name          = local.env.cos_instance_name
  dns_custom_resolver_id     = local.env.dns_custom_resolver_id
  dns_instance_id            = local.env.dns_instance_id
  dns_domain_names           = local.env.dns_domain_names
  dynamic_compute_instances  = local.env.dynamic_compute_instances
  enable_atracker            = local.env.enable_atracker
  enable_bastion             = local.env.enable_bastion
  enable_bootstrap           = local.env.enable_bootstrap
  enable_cos_integration     = local.env.enable_cos_integration
  enable_vpc_flow_logs       = local.env.enable_vpc_flow_logs
  enable_vpn                 = local.env.enable_vpn
  file_shares                = local.env.file_shares
  hpcs_instance_name         = local.env.hpcs_instance_name 
  key_management             = local.env.key_management
  login_image_name           = local.env.login_image_name
  login_instances            = local.env.login_instances
  login_ssh_keys             = local.env.login_ssh_keys
  login_subnets_cidr         = local.env.login_subnets_cidr
  management_image_name      = local.env.management_image_name
  management_instances       = local.env.management_instances
  network_cidr               = local.env.network_cidr
  nsd_details                = local.env.nsd_details
  placement_strategy         = local.env.placement_strategy
  protocol_instances         = local.env.protocol_instances
  protocol_subnets_cidr      = local.env.protocol_subnets_cidr
  static_compute_instances   = local.env.static_compute_instances
  storage_gui_password       = local.env.storage_gui_password
  storage_gui_username       = local.env.storage_gui_username
  storage_image_name         = local.env.storage_image_name
  storage_instances          = local.env.storage_instances
  storage_ssh_keys           = local.env.storage_ssh_keys
  storage_subnets_cidr       = local.env.storage_subnets_cidr
  vpc                        = local.env.vpc
  vpn_peer_address           = local.env.vpn_peer_address
  vpn_peer_cidr              = local.env.vpn_peer_cidr
  vpn_preshared_key          = local.env.vpn_preshared_key
}
