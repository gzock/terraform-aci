terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.7.1"
    }
  }
}

variable "app_prof" {
  type = string
}

variable "useg_epg" {
  type = string
}

variable "matching_exp" {
  type = string
}

variable "ipaddrs" {
  type = list(string)
}


resource "aci_rest" "configure_useg_init" {
	path       = "/api/mo/${var.app_prof}/epg-${var.useg_epg}/crtrn.json"
	class_name = "fvCrtrn"
	content = {
		match = var.matching_exp
	}
}

resource "aci_rest" "configure_useg_ipattr" {
  count = length(var.ipaddrs)
	path       = "/api/mo/${var.app_prof}/epg-${var.useg_epg}/crtrn/ipattr-${count.index}.json"
  class_name = "fvIpAttr"
  content = {
    ip          = var.ipaddrs[count.index]
    usefvSubnet = "no"
  }
  depends_on = [aci_rest.configure_useg_init]
}
