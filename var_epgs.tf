variable "ap_with_epgs" {
  description = "needs endpoint groups"
  type        = map(any)
  default = {
    "EPG_Name" = {
      physical_domain = "Physical_Domain"
      bridge_domain   = "Bridge_Domain"
      attach_nodes = [
        "topology/pod-1/node-201",
        "topology/pod-1/node-202",
      ]
      attach_ports = {
        vlan  = ""
        mode  = ""
        ports = []
      }
      inheritances  = []
      is_useg       = true
      useg_ipaddrs  = ["192.168.0.1"]
      useg_matching = "any"
      subnet_cidr   = ""
      subnet_ctrl   = []
      subnet_scope  = []
    }
  }
}
