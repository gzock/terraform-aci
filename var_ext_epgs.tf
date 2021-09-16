variable "ext_epgs" {
  description = "needs external epgs on l3out"
  type        = map(any)
  default = {
    "External_EPG_Name" = {
      l3out = "Parent_L3out"
      subnets = {
        "Subnet_1" = {
          cidr      = "172.16.0.1/16"
          scope     = ["import-security", "shared-security"]
          aggregate = ""
        }
      }
    }
  }
}
