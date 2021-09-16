# 概要

CiscoACIをTerraformで操作するときのテンプレート的なやつ。  
公式のProviderだと細かいところに手が届かない。例えばuSEGを全くイジれなかったりとか。他にもEPGやContractは大量に用意するだろうけど、そういったループ処理も当然自前で作る必要がある。  
滅多にないけど、そういう用事ができたときに速やかに実装できるようにしておきたい・・・という思いでテンプレを用意しておく。

# モジュール一覧

|モジュール名|内容|
|-|-|
|attach_contract.tf|EPGをコントラクトのConsumer|Providerとしてアタッチする。|
|contract.tf|コントラクト作成のラッパーモジュール。サブジェクト作成まで一括で行う。|
|epg.tf|EPG作成ラッパーモジュール。AP作成～EPG作成～ドメインアタッチ～ポートアタッチまで行う。つまりこれを使えば周辺オブジェクトも含めて一気に作成可能。必要に応じて、IPアドレス属性を使ったuSEG EPGも作成可能。|
|ext_epg.tf|ExternalEPG作成ラッパーモジュール。サブネット指定まで行う。|
|node2epg.tf|EPGにノードをアタッチするモジュール。本来、こういったリソースは公式には用意されていないため、aci_restで独自に作成。|
|ports.tf|EPGにスタティックパス(リーフのポートやVLANのマッピング)を行うモジュール。|
|useg_epg.tf|epg.tfから使用するuSEG EPGを取り扱う専用のモジュール。uSEG関係のリソースは公式には用意されていないため、全面的にaci_restで独自に作成。|

# 使い方

各モジュールを使えば、大量にACIのEPGやContractのオブジェクトを大量に作成できる。uSEG EPGやExternalEPGにも対応。

これだけでOK

```
module "epg" {
  source   = "./modules/epg"
  for_each = var.ap_with_epgs

  tenant   = aci_tenant.common.id
  app_prof = each.key
  epgs     = each.value
}
```

あとはvar_*.tf側をイジる。mapな形でどんどんオブジェクトを増やしていけば良い。これで10個でも100個でもEPGやContractを一気に作成できる。

```
ap_with_epgs  = {
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
```

# 参考

手動でACIのAPIを叩いて特定テナント配下のオブジェクトをぶっこ抜く。

```bash
$ cat login.json
{
  "aaaUser" : {
    "attributes" : {
      "name" : "admin",
      "pwd" : "password"
    }
  }
}
```

```bash
$ curl -k -L -X POST https://example.aci.local/api/aaaLogin.json -d@./login.json -c cookie
$ curl -k "https://example.aci.local/api/mo/uni/tn-common.json?query-target=subtree" -b cookie | jq . > common_subtree.json
```

