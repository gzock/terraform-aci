variable "attach_contract" {
  description = "attach epg to contract "
  type        = map(any)
  default = {
    "Contract_Name" = {
      consumers = [
        "Consumer_EPG_1",
        "Consumer_EPG_2",
      ],
      providers = [
        "Provider_EPG_1",
      ]
    }
  }
}
