resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = var.vcn_cidr
  display_name   = "${var.project_name}-vcn"

  freeform_tags = merge(var.tagging, {
    "Name" = "${var.project_name}-oci-vcn"
    "Type" = "Network"
  })

  lifecycle {
    ignore_changes = [freeform_tags]
  }
}
