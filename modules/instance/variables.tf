variable "compartment_id" { type = string }
variable "vcn_id" { type = string }
variable "region_ad" { type = string }
variable "project_name" { type = string }
variable "tagging" { type = map(string) }

variable "nsg_info" { type = map(object({ id = string })) }
variable "subnet_info" { type = map(object({ id = string })) }
variable "nat_gateway_id" { type = string }

variable "server_config" { type = map(object({ name = string, vcpu = number, storage = number, ip = string, os_image = string })) }
variable "tailscale_authkey" { type = string }
