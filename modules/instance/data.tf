data "oci_core_images" "ubuntu_aarch64" {
  compartment_id   = var.compartment_id
  operating_system = "Canonical Ubuntu"
  shape            = "VM.Standard.A1.Flex"
  state            = "AVAILABLE"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"

  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-24.04-Minimal.*"]
    regex  = true
  }
}

data "oci_core_app_catalog_listings" "this" {
  filter {
    name   = "display_name"
    values = ["^Rocky Linux 9 aarch64.*"]
    regex  = true
  }
}

data "oci_core_app_catalog_listing_resource_versions" "this" {
  listing_id = lookup(data.oci_core_app_catalog_listings.this.app_catalog_listings[0], "listing_id")
}

data "oci_core_app_catalog_subscriptions" "this" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  listing_id = oci_core_app_catalog_subscription.this.listing_id

  filter {
    name   = "listing_resource_version"
    values = ["${oci_core_app_catalog_subscription.this.listing_resource_version}"]
  }
}

data "oci_core_vnic_attachments" "pri_vnic_attachments" {
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.this["main"].id
  depends_on     = [oci_core_instance.this]
}

data "oci_core_private_ips" "pri_private_ips" {
  vnic_id = data.oci_core_vnic_attachments.pri_vnic_attachments.vnic_attachments[0].vnic_id
}
