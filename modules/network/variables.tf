variable "compartment_id" { type = string }
variable "vcn_id" { type = string }
variable "project_name" { type = string }
variable "tagging" { type = map(string) }

variable "server_config" { type = map(object({ name = string, vcpu = number, storage = number, ip = string, os_image = string })) }

variable "network_config" { type = map(object({ cidr = string })) }
variable "nsg_rule" { type = map(object({ type = string, min = number, max = number, protocol = string, direction = string, target = string, target_type = string, description = string })) }
