terraform {
  required_version = ">= 1.3"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.68.1, < 2.0.0"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = local.ibmcloud_api_key
  region           = local.region
}

locals {
  ibmcloud_api_key = "V4cXXyS0ClT5AkdvxB8aH5yI1dIBdS_t8A1QN6seX5VO"
  region           = "jp-tok"
  storage_instances = [{
    profile = "bx2-2x8"
    count   = 2
    image   = "ibm-redhat-8-10-minimal-amd64-2"
    },
    {
      profile = "cx2-2x4"
      count   = 1
      image   = "ibm-redhat-8-8-minimal-amd64-7"
  }]
}

data "ibm_is_image" "storage" {
  count = length(local.storage_instances)
  name  = local.storage_instances[count.index]["image"]
}

output "op" {
  value = data.ibm_is_image.storage[*].id
}

