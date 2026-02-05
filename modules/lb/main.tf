locals {
  lb_configs = {
    http  = { port = 80, protocol = "TCP", health_port = 10080, traefik_port = 10080 }
    https = { port = 443, protocol = "TCP", health_port = 10443, traefik_port = 10443 }
    quic  = { port = 443, protocol = "UDP", health_port = 10080, traefik_port = 10444 }
    dot   = { port = 853, protocol = "TCP", health_port = 10853, traefik_port = 10853 }
    doq   = { port = 853, protocol = "UDP", health_port = 10080, traefik_port = 10854 }
    wg    = { port = 51820, protocol = "UDP", health_port = 10080, traefik_port = 51820 }
  }
}

resource "oci_network_load_balancer_network_load_balancer" "this" {
  #Required
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-oci-nlb"
  subnet_id      = var.subnet_info["pub"].id

  network_security_group_ids = [var.nsg_info["pub"].id]
  is_private                 = false #Public Network Loadbalancer
  nlb_ip_version             = "IPV4"

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-oci-nlb"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

resource "oci_network_load_balancer_backend_set" "this" {
  for_each = local.lb_configs

  health_checker {
    port     = each.value.health_port
    protocol = "TCP"
  }

  name                     = "${var.project_name}-oci-nlb-bendset-${each.key}"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  policy                   = "TWO_TUPLE"
  is_fail_open             = each.key == "wg" ? true : false
  depends_on               = [oci_network_load_balancer_network_load_balancer.this]

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

resource "oci_network_load_balancer_listener" "this" {
  for_each = local.lb_configs

  default_backend_set_name = oci_network_load_balancer_backend_set.this[each.key].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  name                     = "${var.project_name}-oci-nlb-listen-${each.key}"
  protocol                 = each.value.protocol
  port                     = each.value.port
  depends_on               = [oci_network_load_balancer_backend_set.this]

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}


resource "oci_network_load_balancer_backend" "this" {
  for_each = local.lb_configs

  backend_set_name         = oci_network_load_balancer_backend_set.this[each.key].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  port                     = each.value.traefik_port
  name                     = "${var.project_name}-oci-nlb-backend-${each.key}"

  ip_address = var.target_ip
  depends_on = [oci_network_load_balancer_backend_set.this]

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}
