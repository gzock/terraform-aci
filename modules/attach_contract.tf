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

variable "contract" {
 type = string
}

variable "from" {
 type = list(string)
}

variable "dest" {
 type = list(string)
}

variable "epgs" {
  type = any
}

resource "aci_epg_to_contract" "for_consumer" {
  for_each = toset([ for s in toset(var.from): s if s != "any" ])

  application_epg_dn = flatten([for app_prof in var.epgs : [for epg in app_prof.epgs: epg if epg.name == each.value]])[0].id
  contract_dn        = var.contract
  contract_type      = "consumer"

  lifecycle {
    ignore_changes = [
      annotation
    ]
  }
}

resource "aci_epg_to_contract" "for_provider" {
  for_each = toset(var.dest)

  application_epg_dn = flatten([for app_prof in var.epgs : [for epg in app_prof.epgs: epg if epg.name == each.value]])[0].id
  contract_dn        = var.contract
  contract_type      = "provider"

  lifecycle {
    ignore_changes = [
      annotation
    ]
  }
}
