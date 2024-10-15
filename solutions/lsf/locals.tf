# locals needed for landing_zone
locals {
  # Region and Zone calculations
  region = join("-", slice(split("-", var.zones[0]), 0, 2))
}

/*
# locals needed for bootstrap
locals {
  # dependency: landing_zone -> bootstrap
  vpc_id                     = var.vpc == null ? one(module.landing_zone.vpc_id) : var.vpc
  bastion_subnets            = module.landing_zone.bastion_subnets
  kms_encryption_enabled     = var.key_management != null ? true : false
  boot_volume_encryption_key = var.key_management != null ? one(module.landing_zone.boot_volume_encryption_key)["crn"] : null
  existing_kms_instance_guid = var.key_management != null ? module.landing_zone.key_management_guid : null
  # Future use
  # skip_iam_authorization_policy = true
}


# locals needed for landing_zone_vsi
locals {
  # dependency: landing_zone -> bootstrap -> landing_zone_vsi
  bastion_security_group_id  = module.bootstrap.bastion_security_group_id
  bastion_public_key_content = module.bootstrap.bastion_public_key_content

  # dependency: landing_zone -> landing_zone_vsi
  login_subnets    = module.landing_zone.login_subnets
  compute_subnets  = module.landing_zone.compute_subnets
  storage_subnets  = module.landing_zone.storage_subnets
  protocol_subnets = module.landing_zone.protocol_subnets

  #boot_volume_encryption_key = var.key_management != null ? one(module.landing_zone.boot_volume_encryption_key)["crn"] : null
  #skip_iam_authorization_policy = true
  #resource_group_id = data.ibm_resource_group.itself.id
  #vpc_id            = var.vpc == null ? module.landing_zone.vpc_id[0] : data.ibm_is_vpc.itself[0].id
  #vpc_crn           = var.vpc == null ? module.landing_zone.vpc_crn[0] : data.ibm_is_vpc.itself[0].crn
}

# locals needed for file-storage
locals {
  # dependency: landing_zone -> file-storage
  #vpc_id                        = var.vpc == null ? one(module.landing_zone.vpc_id) : var.vpc
  #boot_volume_encryption_key    = var.key_management != null ? one(module.landing_zone.boot_volume_encryption_key)["crn"] : null

  # dependency: landing_zone_vsi -> file-share
  compute_subnet_id         = local.compute_subnets[0].id
  compute_security_group_id = module.landing_zone_vsi.compute_sg_id
  management_instance_count = sum(var.management_instances[*]["count"])
  default_share = local.management_instance_count > 0 ? [
    {
      mount_path = "/mnt/lsf"
      size       = 100
      iops       = 1000
    }
  ] : []
  storage_instance_count = sum(var.storage_instances[*]["count"])
  total_shares           = local.storage_instance_count > 0 ? [] : concat(local.default_share, var.file_shares)
  file_shares = [
    for count in range(length(local.total_shares)) :
    {
      name = format("%s-%s", var.prefix, element(split("/", local.total_shares[count]["mount_path"]), length(split("/", local.total_shares[count]["mount_path"])) - 1))
      size = local.total_shares[count]["size"]
      iops = local.total_shares[count]["iops"]
    }
  ]
}

# locals needed for DNS
locals {
  # dependency: landing_zone -> DNS
  resource_group_id = one(values(one(module.landing_zone.resource_group_id)))
  vpc_crn           = var.vpc == null ? one(module.landing_zone.vpc_crn) : one(data.ibm_is_vpc.itself[*].crn)
  # TODO: Fix existing subnet logic
  #subnets_crn       = var.vpc == null ? module.landing_zone.subnets_crn : ###
  #subnets           = flatten([local.compute_subnets, local.storage_subnets, local.protocol_subnets])
  #subnets_crns      = data.ibm_is_subnet.itself[*].crn
  subnets_crn = module.landing_zone.subnets_crn
  #boot_volume_encryption_key    = var.key_management != null ? one(module.landing_zone.boot_volume_encryption_key)["crn"] : null

  # dependency: landing_zone_vsi -> file-share
}

# locals needed for dns-records
locals {
  # dependency: dns -> dns-records
  dns_instance_id = module.dns.dns_instance_id
  compute_dns_zone_id = one(flatten([
    for dns_zone in module.dns.dns_zone_maps : values(dns_zone) if one(keys(dns_zone)) == var.dns_domain_names["compute"]
  ]))
  storage_dns_zone_id = one(flatten([
    for dns_zone in module.dns.dns_zone_maps : values(dns_zone) if one(keys(dns_zone)) == var.dns_domain_names["storage"]
  ]))
  protocol_dns_zone_id = one(flatten([
    for dns_zone in module.dns.dns_zone_maps : values(dns_zone) if one(keys(dns_zone)) == var.dns_domain_names["protocol"]
  ]))

  # dependency: landing_zone_vsi -> dns-records
  compute_instances  = flatten([module.landing_zone_vsi.management_vsi_data, module.landing_zone_vsi.compute_vsi_data])
  storage_instances  = flatten([module.landing_zone_vsi.storage_vsi_data, module.landing_zone_vsi.protocol_vsi_data])
  protocol_instances = flatten([module.landing_zone_vsi.protocol_vsi_data])

  compute_dns_records = [
    for instance in local.compute_instances :
    {
      name  = instance["name"]
      rdata = instance["ipv4_address"]
    }
  ]
  storage_dns_records = [
    for instance in local.storage_instances :
    {
      name  = instance["name"]
      rdata = instance["ipv4_address"]
    }
  ]
  protocol_dns_records = [
    for instance in local.protocol_instances :
    {
      name  = instance["name"]
      rdata = instance["ipv4_address"]
    }
  ]
}

# locals needed for inventory
locals {
  compute_hosts          = local.compute_instances[*]["ipv4_address"]
  storage_hosts          = local.storage_instances[*]["ipv4_address"]
  compute_inventory_path = "compute.ini"
  storage_inventory_path = "storage.ini"
}

# locals needed for playbook
locals {
  bastion_fip              = module.bootstrap.bastion_fip
  compute_private_key_path = "compute_id_rsa" #checkov:skip=CKV_SECRET_6
  storage_private_key_path = "storage_id_rsa" #checkov:skip=CKV_SECRET_6
  compute_playbook_path    = "compute_ssh.yaml"
  storage_playbook_path    = "storage_ssh.yaml"
}
*/

##############################################################################
# Dynamically Create Default Configuration
##############################################################################

locals {
  # If override is true, parse the JSON from override.json otherwise parse empty string
  # Default override.json location can be replaced by using var.override_json_path
  # Empty string is used to avoid type conflicts with unary operators
  override_json_path = abspath("./override.json")
  override = {
    override = jsondecode(var.override && var.override_json_string == "" ?
      (local.override_json_path == "" ? file("${path.root}/override.json") : file(local.override_json_path))
      :
    "{}")
    override_json_string = jsondecode(var.override_json_string == "" ? "{}" : var.override_json_string)
  }
  override_type = var.override_json_string == "" ? "override" : "override_json_string"
}

##############################################################################
# Dynamic configuration for landing zone environment
##############################################################################

locals {
  config = {
    allowed_cidr               = var.allowed_cidr
    bootstrap_instance_profile = var.bootstrap_instance_profile
    bastion_ssh_keys           = var.bastion_ssh_keys
    bastion_subnets_cidr       = var.bastion_subnets_cidr
    compute_gui_password       = var.compute_gui_password
    compute_gui_username       = var.compute_gui_username
    compute_image_name         = var.compute_image_name
    compute_ssh_keys           = var.compute_ssh_keys
    compute_subnets_cidr       = var.compute_subnets_cidr
    cos_instance_name          = var.cos_instance_name
    dns_custom_resolver_id     = var.dns_custom_resolver_id
    dns_instance_id            = var.dns_instance_id
    dns_domain_names           = var.dns_domain_names
    dynamic_compute_instances  = var.dynamic_compute_instances
    enable_atracker            = var.enable_atracker
    enable_bastion             = var.enable_bastion
    enable_bootstrap           = var.enable_bootstrap
    enable_cos_integration     = var.enable_cos_integration
    enable_vpc_flow_logs       = var.enable_vpc_flow_logs
    enable_vpn                 = var.enable_vpn
    file_shares                = var.file_shares
    hpcs_instance_name         = var.hpcs_instance_name
    ibm_customer_number        = var.ibm_customer_number
    ibmcloud_api_key           = var.ibmcloud_api_key
    key_management             = var.key_management
    login_image_name           = var.login_image_name
    login_instances            = var.login_instances
    login_ssh_keys             = var.login_ssh_keys
    login_subnets_cidr         = var.login_subnets_cidr
    management_image_name      = var.management_image_name
    management_instances       = var.management_instances
    network_cidr               = var.network_cidr
    nsd_details                = var.nsd_details
    placement_strategy         = var.placement_strategy
    prefix                     = var.prefix
    protocol_instances         = var.protocol_instances
    protocol_subnets_cidr      = var.protocol_subnets_cidr
    resource_group             = var.resource_group
    scheduler                  = var.scheduler
    static_compute_instances   = var.static_compute_instances
    storage_gui_password       = var.storage_gui_password
    storage_gui_username       = var.storage_gui_username
    storage_image_name         = var.storage_image_name
    storage_instances          = var.storage_instances
    storage_ssh_keys           = var.storage_ssh_keys
    storage_subnets_cidr       = var.storage_subnets_cidr
    vpc                        = var.vpc
    vpn_peer_address           = var.vpn_peer_address
    vpn_peer_cidr              = var.vpn_peer_cidr
    vpn_preshared_key          = var.vpn_preshared_key
    zones                      = var.zones
  }
}

##############################################################################
# Compile Environment for Config output
##############################################################################
locals {
  env = {
    allowed_cidr               = lookup(local.override[local.override_type], "allowed_cidr", local.config.allowed_cidr)
    bootstrap_instance_profile = lookup(local.override[local.override_type], "bootstrap_instance_profile", local.config.bootstrap_instance_profile)
    bastion_ssh_keys           = lookup(local.override[local.override_type], "bastion_ssh_keys", local.config.bastion_ssh_keys)
    bastion_subnets_cidr       = lookup(local.override[local.override_type], "bastion_subnets_cidr", local.config.bastion_subnets_cidr)
    compute_gui_password       = lookup(local.override[local.override_type], "compute_gui_password", local.config.compute_gui_password)
    compute_gui_username       = lookup(local.override[local.override_type], "compute_gui_username", local.config.compute_gui_username)
    compute_image_name         = lookup(local.override[local.override_type], "compute_image_name", local.config.compute_image_name)
    compute_ssh_keys           = lookup(local.override[local.override_type], "compute_ssh_keys", local.config.compute_ssh_keys)
    compute_subnets_cidr       = lookup(local.override[local.override_type], "compute_subnets_cidr", local.config.compute_subnets_cidr)
    cos_instance_name          = lookup(local.override[local.override_type], "cos_instance_name", local.config.cos_instance_name)
    dns_custom_resolver_id     = lookup(local.override[local.override_type], "dns_custom_resolver_id", local.config.dns_custom_resolver_id)
    dns_instance_id            = lookup(local.override[local.override_type], "dns_instance_id", local.config.dns_instance_id)
    dns_domain_names           = lookup(local.override[local.override_type], "dns_domain_names", local.config.dns_domain_names)
    dynamic_compute_instances  = lookup(local.override[local.override_type], "dynamic_compute_instances", local.config.dynamic_compute_instances)
    enable_atracker            = lookup(local.override[local.override_type], "enable_atracker", local.config.enable_atracker)
    enable_bastion             = lookup(local.override[local.override_type], "enable_bastion", local.config.enable_bastion)
    enable_bootstrap           = lookup(local.override[local.override_type], "enable_bootstrap", local.config.enable_bootstrap)
    enable_cos_integration     = lookup(local.override[local.override_type], "enable_cos_integration", local.config.enable_cos_integration)
    enable_vpc_flow_logs       = lookup(local.override[local.override_type], "enable_vpc_flow_logs", local.config.enable_vpc_flow_logs)
    enable_vpn                 = lookup(local.override[local.override_type], "enable_vpn", local.config.enable_vpn)
    file_shares                = lookup(local.override[local.override_type], "file_shares", local.config.file_shares)
    hpcs_instance_name         = lookup(local.override[local.override_type], "hpcs_instance_name", local.config.hpcs_instance_name)
    ibm_customer_number        = lookup(local.override[local.override_type], "ibm_customer_number", local.config.ibm_customer_number)
    ibmcloud_api_key           = lookup(local.override[local.override_type], "ibmcloud_api_key", local.config.ibmcloud_api_key)
    key_management             = lookup(local.override[local.override_type], "key_management", local.config.key_management)
    login_image_name           = lookup(local.override[local.override_type], "login_image_name", local.config.login_image_name)
    login_instances            = lookup(local.override[local.override_type], "login_instances", local.config.login_instances)
    login_ssh_keys             = lookup(local.override[local.override_type], "login_ssh_keys", local.config.login_ssh_keys)
    login_subnets_cidr         = lookup(local.override[local.override_type], "login_subnets_cidr", local.config.login_subnets_cidr)
    management_image_name      = lookup(local.override[local.override_type], "management_image_name", local.config.management_image_name)
    management_instances       = lookup(local.override[local.override_type], "management_instances", local.config.management_instances)
    network_cidr               = lookup(local.override[local.override_type], "network_cidr", local.config.network_cidr)
    nsd_details                = lookup(local.override[local.override_type], "nsd_details", local.config.nsd_details)
    placement_strategy         = lookup(local.override[local.override_type], "placement_strategy", local.config.placement_strategy)
    prefix                     = lookup(local.override[local.override_type], "prefix", local.config.prefix)
    protocol_instances         = lookup(local.override[local.override_type], "protocol_instances", local.config.protocol_instances)
    protocol_subnets_cidr      = lookup(local.override[local.override_type], "protocol_subnets_cidr", local.config.protocol_subnets_cidr)
    resource_group             = lookup(local.override[local.override_type], "resource_group", local.config.resource_group)
    scheduler                  = lookup(local.override[local.override_type], "scheduler", local.config.scheduler)
    static_compute_instances   = lookup(local.override[local.override_type], "static_compute_instances", local.config.static_compute_instances)
    storage_gui_password       = lookup(local.override[local.override_type], "storage_gui_password", local.config.storage_gui_password)
    storage_gui_username       = lookup(local.override[local.override_type], "storage_gui_username", local.config.storage_gui_username)
    storage_image_name         = lookup(local.override[local.override_type], "storage_image_name", local.config.storage_image_name)
    storage_instances          = lookup(local.override[local.override_type], "storage_instances", local.config.storage_instances)
    storage_ssh_keys           = lookup(local.override[local.override_type], "storage_ssh_keys", local.config.storage_ssh_keys)
    storage_subnets_cidr       = lookup(local.override[local.override_type], "storage_subnets_cidr", local.config.storage_subnets_cidr)
    vpc                        = lookup(local.override[local.override_type], "vpc", local.config.vpc)
    vpn_peer_address           = lookup(local.override[local.override_type], "vpn_peer_address", local.config.vpn_peer_address)
    vpn_peer_cidr              = lookup(local.override[local.override_type], "vpn_peer_cidr", local.config.vpn_peer_cidr)
    vpn_preshared_key          = lookup(local.override[local.override_type], "vpn_preshared_key", local.config.vpn_preshared_key)
    zones                      = lookup(local.override[local.override_type], "zones", local.config.zones)
  }
}