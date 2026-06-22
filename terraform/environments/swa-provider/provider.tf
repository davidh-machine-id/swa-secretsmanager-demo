# provider.tf

terraform {
  required_providers {
    swa = {
      source  = "registry.terraform.io/cyberark/swa"
      version = "0.1.0-51fb890b-854"
    }
  }
}

provider "swa" {}
