output "nsg_info" {
  value = {
    for k, v in oci_core_network_security_group.this :
    k => ({
      id           = v.id
      display_name = v.display_name
    })
  }
  description = "A map of nsg id"
}

output "subnet_info" {
  value = {
    for k, v in oci_core_subnet.this :
    k => ({
      id           = v.id
      display_name = v.display_name
    })
  }
  description = "A map of subnet id"
}

output "nat_gateway_id" {
  value = oci_core_nat_gateway.this.id
}
