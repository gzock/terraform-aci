module "contract" {
  source   = "./modules/contract"
  for_each = var.contracts

  tenant   = aci_tenant.common.id
  contract = each.key
  scope    = each.value.scope
  filters  = each.value.filters
}

module "attach_contract" {
  source   = "./modules/attach_contract"
  for_each = var.attach_contract

  tenant   = aci_tenant.common.id
  contract = module.contract[each.key].contract.id
  from     = each.value.consumers
  dest     = each.value.providers
  epgs = merge(
    module.epg,
    module.ext_epg,
  )
  depends_on = [module.contract]
}

resource "aci_any" "configure_vzany" {
  vrf_dn                     = aci_vrf.common.id
  relation_vz_rs_any_to_cons = [for k, v in var.attach_contract : "uni/tn-common/brc-${k}" if contains(v.consumers, "any")]
}
