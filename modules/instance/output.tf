output "image_catalog" {
  value = [
    for img in data.oci_core_app_catalog_listings.this.app_catalog_listings : {
      id   = img.listing_id
      name = img.display_name
    }
  ]
}

output "image_catalog_resource_ver" {
  value = {
    id  = oci_core_app_catalog_listing_resource_version_agreement.this.listing_id
    ver = oci_core_app_catalog_listing_resource_version_agreement.this.listing_resource_version
  }
}
