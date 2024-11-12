data "ibm_dns_zones" "itself" {
  count = var.enable_deployer == false ? 1 : 0
  instance_id = var.dns_instance_id
}

locals {
  dns_domain_name = var.enable_deployer == false ? [
    for zone in data.ibm_dns_zones.itself[*].dns_zones : zone["name"] if zone["zone_id"] == var.dns_zone_id
  ] : []
}

resource "ibm_dns_resource_record" "a" {
  count       = var.enable_deployer == false ? length(var.dns_records) : 0 
  instance_id = var.dns_instance_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = var.dns_records[count.index]["name"]
  rdata       = var.dns_records[count.index]["rdata"]
  ttl         = 300
}

resource "ibm_dns_resource_record" "ptr" {
  count       = var.enable_deployer == false ? length(var.dns_records) : 0
  instance_id = var.dns_instance_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = var.dns_records[count.index]["rdata"]
  rdata       = format("%s.%s", var.dns_records[count.index]["name"], one(local.dns_domain_name))
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.a]
}
