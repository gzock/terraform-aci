module "ext_epg" {
  source   = "./modules/ext_epg"
  for_each = var.ext_epgs

  tenant  = aci_tenant.common.id
  name    = each.key
  l3out   = each.value.l3out
  subnets = each.value.subnets
}
