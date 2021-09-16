##contract##
terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.7.1"
    }
  }
}

variable "tenant" {
 type = string
}

variable "tenant_with_filters" {
 type = string
 default = "uni/tn-common"
}


variable "contract" {
 type = string
}

variable "filters" {
 type = list(string)
}

variable "scope" {
  type = string
}

resource "aci_contract" "configure_contract" {
  tenant_dn = var.tenant
  name      = var.contract
  scope     = var.scope

  lifecycle {
    ignore_changes = [
      filter_ids,
      filter_entry_ids
    ]
  }
}

resource "aci_contract_subject" "configure_subject" {
  contract_dn                  = aci_contract.configure_contract.id
  name                         = "${var.contract}_Sub"
  relation_vz_rs_subj_filt_att = [ for filter in var.filters: "${var.tenant_with_filters}/flt-${filter}" ]
  depends_on = [aci_contract.configure_contract]
}

output "contract" {
  value = aci_contract.configure_contract
}
