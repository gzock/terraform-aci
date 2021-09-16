terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.7.1"
    }
  }
}

variable "epg" {
  type = string
}

variable "vlan" {
  type = string
}

variable "mode" {
  type = string
}

variable "ports" {
  type = list(string)
}

resource "aci_epg_to_static_path" "attach_ports" {
  for_each = toset(var.ports)

  application_epg_dn  = var.epg
  tdn                 = each.value
  encap               = "vlan-${var.vlan}"
  mode                = var.mode
}
