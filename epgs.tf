module "epg" {
  source   = "./modules/epg"
  for_each = var.ap_with_epgs

  tenant   = aci_tenant.common.id
  app_prof = each.key
  epgs     = each.value
}
