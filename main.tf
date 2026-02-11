locals {
  tagging = {
    "Project"     = "${var.project_config["main"].name}"
    "Provisioner" = "Terraform"
    "Owner"       = "${var.project_config["main"].owner}"
    "CreateTime"  = "${formatdate("YYYY-MM-DD hh:mm:ss", timeadd(timestamp(), "9h"))} KST"
  }
  project_prefix = "${var.project_config["main"].name}-${var.project_config["main"].location}"
}

module "vcn" {
  source         = "./modules/vcn"
  project_name   = local.project_prefix
  compartment_id = data.sops_file.secret.data["tenancy_id"]
  tagging        = local.tagging
  vcn_cidr       = var.vcn_cidr
}

module "network" {
  source         = "./modules/network"
  project_name   = local.project_prefix
  compartment_id = data.sops_file.secret.data["tenancy_id"]
  tagging        = local.tagging

  depends_on = [module.vcn]

  vcn_id = module.vcn.vcn_id

  server_config = var.server_config

  network_config = var.network_config
  nsg_rule       = var.nsg_rule
}

module "lb" {
  source         = "./modules/lb"
  project_name   = local.project_prefix
  compartment_id = data.sops_file.secret.data["tenancy_id"]
  tagging        = local.tagging
  subnet_info    = module.network.subnet_info

  depends_on = [module.network]

  vcn_id    = module.vcn.vcn_id
  nsg_info  = module.network.nsg_info
  target_ip = var.server_config["gateway"].ip
}

module "instance" {
  source         = "./modules/instance"
  project_name   = local.project_prefix
  compartment_id = data.sops_file.secret.data["tenancy_id"]
  region_ad      = var.region_ad
  tagging        = local.tagging

  depends_on = [module.lb]

  vcn_id = module.vcn.vcn_id

  subnet_info    = module.network.subnet_info
  nsg_info       = module.network.nsg_info
  nat_gateway_id = module.network.nat_gateway_id

  server_config = var.server_config
  public_key    = data.sops_file.secret.data["ssh_pub"]
  ts_authkey    = data.sops_file.secret.data["ts_authkey"]
  wg0_conf      = data.sops_file.secret.data["wg0_conf"]
}
