locals {
  lb_configs = {
    http = { port = 80, protocol = "TCP", health_port = 80, internal_port = 80 }
    tls  = { port = 443, protocol = "TCP_AND_UDP", health_port = 443, internal_port = 443 }
    dns  = { port = 853, protocol = "TCP_AND_UDP", health_port = 853, internal_port = 853 }
    wg   = { port = 51820, protocol = "UDP", health_port = 80, internal_port = 51820 }
  }
}

resource "oci_network_load_balancer_network_load_balancer" "this" {
  #Required
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-nlb"
  subnet_id      = var.subnet_info["pub"].id

  network_security_group_ids = [var.nsg_info["pub"].id]
  is_private                 = false #Public LB
  nlb_ip_version             = "IPV4"

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-nlb"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}

resource "oci_network_load_balancer_backend_set" "this" {
  for_each = local.lb_configs

  health_checker {
    port     = each.value.health_port
    protocol = "TCP"
  }

  name                     = "${var.project_name}-nlb-bes-${each.key}"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  policy                   = "TWO_TUPLE"
  is_fail_open             = each.key == "wg" ? true : false
  depends_on               = [oci_network_load_balancer_network_load_balancer.this]
}

resource "oci_network_load_balancer_listener" "this" {
  for_each = local.lb_configs

  default_backend_set_name = oci_network_load_balancer_backend_set.this[each.key].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  name                     = "${var.project_name}-nlb-listen-${each.key}"
  protocol                 = each.value.protocol
  port                     = each.value.port
  depends_on               = [oci_network_load_balancer_backend_set.this]
}

resource "oci_network_load_balancer_backend" "this" {
  for_each = local.lb_configs

  backend_set_name         = oci_network_load_balancer_backend_set.this[each.key].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  port                     = each.value.internal_port
  name                     = "${var.project_name}-nlb-backend-${each.key}"

  ip_address = var.target_ip
  depends_on = [oci_network_load_balancer_backend_set.this]
}
