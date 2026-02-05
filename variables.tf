#provider
variable "api_fingerprint" { type = string }
variable "api_private_key_path" { type = string }
variable "tenancy_id" { type = string }
variable "user_id" { type = string }
variable "region" { type = string }
variable "region_ad" { type = string }

#app
variable "project_name" { type = string }
variable "owner" { type = string }

#server
variable "server_config" { type = map(object({ name = string, vcpu = number, storage = number, ip = string, os_image = string })) }
variable "tailscale_authkey" { type = string }

#network
variable "vcn_cidr" { type = list(string) }
variable "network_config" { type = map(object({ cidr = string })) }
variable "nsg_rule" { type = map(object({ type = string, min = number, max = number, protocol = string, direction = string, target = string, target_type = string, description = string })) }
