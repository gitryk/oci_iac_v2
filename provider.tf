terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 8.0.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.3.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = data.sops_file.secret.data["tenancy_id"]
  user_ocid    = data.sops_file.secret.data["user_id"]
  fingerprint  = data.sops_file.secret.data["api_fingerprint"]
  private_key  = data.sops_file.secret.data["api_key"]
  region       = var.region
}
