locals {
  wireguard_conf = base64encode(file("./script/wg0.conf"))

  os_images_map = {
    "rocky"  = oci_core_app_catalog_subscription.this.listing_resource_id
    "ubuntu" = data.oci_core_images.ubuntu_aarch64.images[0].id
  }
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "this" {
  listing_id               = lookup(data.oci_core_app_catalog_listing_resource_versions.this.app_catalog_listing_resource_versions[0], "listing_id")
  listing_resource_version = lookup(data.oci_core_app_catalog_listing_resource_versions.this.app_catalog_listing_resource_versions[0], "listing_resource_version")
}

resource "oci_core_app_catalog_subscription" "this" {
  compartment_id           = var.compartment_id
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.this.eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.this.listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.this.listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.this.oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.this.signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.this.time_retrieved

  timeouts {
    create = "15m"
  }
}

resource "oci_core_instance" "this" {
  for_each = var.server_config

  availability_domain  = var.region_ad
  compartment_id       = var.compartment_id
  display_name         = "${var.project_name}-oci-vm-${each.value.name}"
  preserve_boot_volume = "false"

  shape = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = each.value.vcpu     #core
    memory_in_gbs = each.value.vcpu * 6 #ram
  }

  source_details {
    source_id               = local.os_images_map[each.value.os_image]
    source_type             = "image"
    boot_volume_size_in_gbs = each.value.storage #boot disk 크기
  }

  metadata = {
    ssh_authorized_keys = sensitive(file("./keys/instance/public.key"))
    user_data           = sensitive(base64encode(templatefile("./script/cloud_init.sh", { wireguard_conf = local.wireguard_conf, os_image = each.value.os_image, install_target = each.key, tailscale_authkey = var.tailscale_authkey })))
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  create_vnic_details {
    assign_public_ip          = false #public ip allow or not
    assign_ipv6ip             = false
    assign_private_dns_record = false
    skip_source_dest_check    = true
    display_name              = "${var.project_name}-oci-${each.value.name}-vnic"
    nsg_ids                   = [var.nsg_info["pri"].id]
    private_ip                = each.value.ip
    subnet_id                 = var.subnet_info["pri"].id
  }

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-oci-vm-${each.value.name}"
    "Type" = "Instance"
    "OS"   = "${each.value.os_image}"
    "Spec" = "vCPU ${each.value.vcpu} Core / RAM ${each.value.vcpu * 6} GB / DISK ${each.value.storage} GB"
    "IP"   = "${each.value.ip}"
  })

  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
      #metadata.user_data,
      create_vnic_details[0].display_name,
      freeform_tags
    ]
  }

  depends_on = [oci_core_app_catalog_subscription.this]
}

#define route table for private subnet
resource "oci_core_route_table" "pri_route" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name = "${var.project_name}-oci-route-pri"
  route_rules {
    network_entity_id = data.oci_core_private_ips.pri_private_ips.private_ips[0].id
    destination       = "172.16.0.0/29"
    destination_type  = "CIDR_BLOCK"
    description       = "WireGuard Range"
  }

  route_rules {
    network_entity_id = var.nat_gateway_id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-oci-route-pri"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }

  depends_on = [oci_core_instance.this]
}

resource "oci_core_route_table_attachment" "pri_route_attach" {
  subnet_id      = var.subnet_info["pri"].id
  route_table_id = oci_core_route_table.pri_route.id

  depends_on = [oci_core_route_table.pri_route]
}
