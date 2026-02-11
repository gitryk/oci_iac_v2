#IGW
resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name = "${var.project_name}-igw"

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-igw"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}

#NAT
resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name = "${var.project_name}-nat"

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-nat"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}

#기본 보안 그룹(깡통)
resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name = "${var.project_name}-seculist"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-seculist"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}

#서브넷 생성
resource "oci_core_subnet" "this" {
  for_each = var.network_config

  cidr_block     = var.network_config[each.key].cidr
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  #Optional
  display_name = "${var.project_name}-sub-${each.key}"
  prohibit_public_ip_on_vnic = (
    each.key == "pub"
    ? false
    : true
  )
  security_list_ids = [oci_core_security_list.this.id]

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-sub-${each.key}"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}

#라우팅 테이블 두개 생성
resource "oci_core_route_table" "pub_route" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name = "${var.project_name}-route-pub"
  route_rules {
    network_entity_id = oci_core_internet_gateway.this.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  depends_on = [oci_core_internet_gateway.this, oci_core_nat_gateway.this]

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-route-pub"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}

resource "oci_core_route_table_attachment" "pub_routeroute_attach" {
  subnet_id      = oci_core_subnet.this["pub"].id
  route_table_id = oci_core_route_table.pub_route.id
}

#역할별 nsg 생성
resource "oci_core_network_security_group" "this" {
  for_each       = var.network_config
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name = "${var.project_name}-nsg-${each.key}"

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-nsg-${each.key}"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}

#security rule 연결
resource "oci_core_network_security_group_security_rule" "this" {
  for_each = var.nsg_rule

  protocol  = lookup({ icmp = "1", tcp = "6", udp = "17", icmpv6 = "58" }, lower(each.value.protocol), "all")
  direction = each.value.direction

  network_security_group_id = oci_core_network_security_group.this[each.value.type].id

  source_type = each.value.direction == "INGRESS" ? each.value.target_type : null
  source = each.value.direction == "INGRESS" ? (
    each.value.target_type == "CIDR_BLOCK"
    ? each.value.target
    : oci_core_network_security_group.this[each.value.target].id
  ) : null

  destination_type = each.value.direction == "EGRESS" ? each.value.target_type : null
  destination = each.value.direction == "EGRESS" ? (
    each.value.target_type == "CIDR_BLOCK"
    ? each.value.target
    : oci_core_network_security_group.this[each.value.target].id
  ) : null

  dynamic "icmp_options" {
    for_each = (
      contains(["icmp", "icmpv6"], lower(coalesce(each.value.protocol, ""))) && each.value.min != null
    ) ? [1] : []

    content {
      type = each.value.min
      code = each.value.max
    }
  }

  dynamic "tcp_options" {
    for_each = each.value.protocol == "tcp" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.direction == "INGRESS" ? [1] : []
        content {
          min = each.value.min
          max = coalesce(each.value.max, each.value.min)
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.direction == "EGRESS" ? [1] : []
        content {
          min = each.value.min
          max = coalesce(each.value.max, each.value.min)
        }
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "udp" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.direction == "INGRESS" ? [1] : []
        content {
          min = each.value.min
          max = coalesce(each.value.max, each.value.min)
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.direction == "EGRESS" ? [1] : []
        content {
          min = each.value.min
          max = coalesce(each.value.max, each.value.min)
        }
      }
    }
  }

  description = each.value.description
  depends_on  = [oci_core_network_security_group.this]
}
