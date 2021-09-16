terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.7.1"
    }
  }
}

variable "path" {
  type = string
}

variable "nodes" {
  type = list(string)
}

resource "aci_rest" "attach_nodes" {
  for_each = toset(var.nodes)

  path       = var.path
  class_name = "fvRsNodeAtt"
  content = {
    instrImedcy = "immediate"
    mode        = "regular"
    tDn         = each.value
  }
}
