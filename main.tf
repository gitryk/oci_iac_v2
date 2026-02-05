locals {
  tagging = {
    "Project"     = "${var.project_name}"
    "Provisioner" = "Terraform"
    "Owner"       = "${var.owner}"
    "CreateTime"  = "${formatdate("YYYY-MM-DD hh:mm:ss", timeadd(timestamp(), "9h"))} KST"
  }
}

module "vcn" {
  source         = "./modules/vcn"
  project_name   = var.project_name
  compartment_id = var.tenancy_id
  tagging        = local.tagging
  vcn_cidr       = var.vcn_cidr
}

module "network" {
  source         = "./modules/network"
  project_name   = var.project_name
  compartment_id = var.tenancy_id
  tagging        = local.tagging

  depends_on = [module.vcn]

  vcn_id = module.vcn.vcn_id

  server_config = var.server_config

  network_config = var.network_config
  nsg_rule       = var.nsg_rule
}

module "lb" {
  source         = "./modules/lb"
  project_name   = var.project_name
  compartment_id = var.tenancy_id
  tagging        = local.tagging
  subnet_info    = module.network.subnet_info

  depends_on = [module.network]

  vcn_id    = module.vcn.vcn_id
  nsg_info  = module.network.nsg_info
  target_ip = var.server_config["main"].ip
}

module "instance" {
  source         = "./modules/instance"
  project_name   = var.project_name
  compartment_id = var.tenancy_id
  region_ad      = var.region_ad
  tagging        = local.tagging

  depends_on = [module.lb]

  vcn_id = module.vcn.vcn_id

  subnet_info    = module.network.subnet_info
  nsg_info       = module.network.nsg_info
  nat_gateway_id = module.network.nat_gateway_id

  server_config     = var.server_config
  tailscale_authkey = var.tailscale_authkey
}


