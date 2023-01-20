terraform {
  cloud {
    organization = "2Tier-Cloud"

    workspaces {
      name = "Terraform-2tier"
    }
  }
}