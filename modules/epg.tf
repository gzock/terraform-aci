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

variable "app_prof" {
  type = string
}

variable "epgs" {
  type = map
}

resource "aci_application_profile" "configure_app_prof" {
  tenant_dn = var.tenant
  name      = var.app_prof
}

output "app_prof" {
  value = aci_application_profile.configure_app_prof
}

resource "aci_application_epg" "configure_epg" {
  application_profile_dn = aci_application_profile.configure_app_prof.id
  for_each = var.epgs

  name                         = each.key
  is_attr_based_epg            = each.value.is_useg ? "yes" : "no"
  #flood_on_encap               = each.value.flood_on_encap
  relation_fv_rs_bd            = "${var.tenant}/BD-${each.value.bridge_domain}"
  relation_fv_rs_sec_inherited = each.value.inheritances

  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
      relation_fv_rs_node_att
    ]
  }
}

output "epgs" {
  value = aci_application_epg.configure_epg
}

resource "aci_epg_to_domain" "attach_physical_domain" {
  for_each = {for ap, epg in var.epgs: ap => epg if epg.physical_domain != ""}

  application_epg_dn    = "${aci_application_profile.configure_app_prof.id}/epg-${each.key}"
  tdn                   = "uni/phys-${each.value.physical_domain}"
  depends_on = [aci_application_epg.configure_epg]
}

resource "aci_subnet" "attach_subnet" {
  for_each = {for epg, params in var.epgs: epg => params if params.subnet_cidr != ""}

  parent_dn = "${aci_application_profile.configure_app_prof.id}/epg-${each.key}"
  ctrl      = each.value.subnet_ctrl
  ip        = each.value.subnet_cidr
  scope     = each.value.subnet_scope
  depends_on = [aci_application_epg.configure_epg]
}

module "useg" {
  source       = "./useg"
  for_each = {for ap, epg in var.epgs: ap => epg if epg.is_useg}

  app_prof     = aci_application_profile.configure_app_prof.id
  useg_epg     = each.key
  matching_exp = each.value.useg_matching
  ipaddrs         = each.value.useg_ipaddrs
  depends_on = [aci_application_epg.configure_epg]
}

module "node_to_epg" {
  source     = "./node2epg"
  for_each   = {for ap, epg in var.epgs: ap => epg if length(epg.attach_nodes) > 0}

  path       = "/api/mo/${aci_application_profile.configure_app_prof.id}/epg-${each.key}.json"
  nodes      = each.value.attach_nodes
  depends_on = [aci_application_epg.configure_epg]
}

module "attach_ports" {
  source     = "./attach_ports"
  for_each = {for ap, epg in var.epgs: ap => epg if length(epg.attach_ports.ports) > 0}

  epg        = "${aci_application_profile.configure_app_prof.id}/epg-${each.key}"
  vlan       = each.value.attach_ports.vlan
  mode       = each.value.attach_ports.mode
  ports      = each.value.attach_ports.ports
  depends_on = [aci_application_epg.configure_epg]
}
