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

variable "name" {
  type = string
}

variable "l3out" {
  type = string
}

variable "subnets" {
  type = map
}

resource "aci_external_network_instance_profile" "configure_external_epg" {
  l3_outside_dn  = "${var.tenant}/out-${var.l3out}"
  name           = var.name
}

output "external_epg" {
  value = aci_external_network_instance_profile.configure_external_epg
}

output "epgs" {
  value = { "${var.name}" = aci_external_network_instance_profile.configure_external_epg }
}

resource "aci_l3_ext_subnet" "configure_attributes" {
  for_each = {for name, params in var.subnets: name => params if params.aggregate == ""}

  external_network_instance_profile_dn  = aci_external_network_instance_profile.configure_external_epg.id
  ip                                    = each.value.cidr
  scope                                 = each.value.scope
}

resource "aci_l3_ext_subnet" "configure_attributes_with_aggregate_param" {
  for_each = {for name, params in var.subnets: name => params if params.aggregate != ""}

  external_network_instance_profile_dn  = aci_external_network_instance_profile.configure_external_epg.id
  ip                                    = each.value.cidr
  scope                                 = each.value.scope
  aggregate                             = each.value.aggregate
}

output "attributes" {
  value = aci_l3_ext_subnet.configure_attributes
}
