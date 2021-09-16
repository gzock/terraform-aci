variable "contracts" {
  description = "needs contract and subject"
  type        = map(any)
  default = {
    "Contract_Name" = {
      "scope" = "global"
      "filters" = [
        "Filter_1",
        "Filter_2",
      ]
    }
  }
}
