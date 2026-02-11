variable "compartment_id" { type = string }
variable "vcn_id" { type = string }
variable "project_name" { type = string }
variable "tagging" { type = map(string) }
variable "nsg_info" { type = map(object({ id = string })) }
variable "subnet_info" { type = map(object({ id = string })) }
variable "target_ip" { type = string }
