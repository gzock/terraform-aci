terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = "0.7.1"
    }
  }
}

terraform {
  backend "s3" {}
}

provider "aci" {
  username = "admin"
  password = "admin"
  url      = "https://example.aci.local"
  insecure = true
}

resource "aci_tenant" "common" {
  name = "common"
}

resource "aci_vrf" "common" {
  tenant_dn              = aci_tenant.common.id
  name                   = "Common_VRF"
  bd_enforced_enable     = "no"
  ip_data_plane_learning = "enabled"
}
