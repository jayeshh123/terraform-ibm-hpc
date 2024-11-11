data "template_file" "bastion_user_data" {
  template = file("${path.module}/templates/bastion_user_data.tpl")
  vars = {
    ssh_public_key_content = local.enable_bastion ? module.ssh_key[0].public_key_content : null
  }
}

data "template_file" "deployer_user_data" {
  template = file("${path.module}/templates/deployer_user_data.tpl")
  vars = {
    bastion_public_key_content   = local.enable_bastion ? module.ssh_key[0].public_key_content : null
    remote_ansible_path          = local.enable_bastion ? local.remote_ansible_path : null
    da_hpc_repo_tag              = local.enable_bastion ? local.da_hpc_repo_tag : null
    da_hpc_repo_url              = local.enable_bastion ? local.da_hpc_repo_url : null
    scale_cloud_deployer_path    = local.enable_bastion ? local.scale_cloud_deployer_path : null
    scale_cloud_install_repo_name= local.enable_bastion ? local.scale_cloud_install_repo_name : null
    scale_cloud_install_repo_url = local.enable_bastion ? local.scale_cloud_install_repo_url : null
    scale_cloud_install_tag      = local.enable_bastion ? local.scale_cloud_install_tag : null
    scale_cloud_infra_repo_name  = local.enable_bastion ? local.scale_cloud_infra_repo_name : null
    scale_cloud_infra_repo_url   = local.enable_bastion ? local.scale_cloud_infra_repo_url : null
    scale_cloud_infra_repo_tag   = local.enable_bastion ? local.scale_cloud_infra_repo_tag : null
    ibmcloud_api_key             = local.enable_bastion ? var.ibmcloud_api_key : null
    ibm_customer_number          = local.enable_bastion ? var.ibm_customer_number : null
    resource_group               = local.enable_bastion ? var.resource_group : null
    prefix                       = local.enable_bastion ? var.prefix : null
    allowed_cidr                 = local.enable_bastion ? jsonencode(var.allowed_cidr) : null 
    zones                        = local.enable_bastion ? var.zones[0] : null
    compute_ssh_keys             = local.enable_bastion ? jsonencode(var.compute_ssh_keys) : null
    storage_ssh_keys             = local.enable_bastion ? jsonencode(var.storage_ssh_keys) : null
    enable_bastion               = local.enable_bastion ? local.enable_bastion : null
    storage_instances            = local.enable_bastion ? jsonencode(var.storage_instances) : null
    protocol_instances           = local.enable_bastion ? jsonencode(var.protocol_instances) : null
    compute_instances            = local.enable_bastion ? jsonencode(var.compute_instances) : null
    client_instances             = local.enable_bastion ? jsonencode(var.client_instances) : null
    enable_cos_integration       = local.enable_bastion ? var.enable_cos_integration : null
    enable_atracker              = local.enable_bastion ? var.enable_atracker : null
    enable_vpc_flow_logs         = local.enable_bastion ? var.enable_vpc_flow_logs : null
    key_management               = local.enable_bastion ? jsonencode(var.key_management) : null
    vpc_id                       = local.enable_bastion ? var.vpc_id : null
    storage_subnets              = local.enable_bastion ? jsonencode(var.storage_subnets) : null
    protocol_subnets             = local.enable_bastion ? jsonencode(var.protocol_subnets) : null
    compute_subnets              = local.enable_bastion ? jsonencode(var.compute_subnets) : null
    client_subnets               = local.enable_bastion ? jsonencode(var.client_subnets) : null
    bastion_fip                  = local.enable_bastion ? var.bastion_fip : null
  }
}
