output "images" {
  value = module.instance.image_catalog
}

output "images_resource_ver" {
  value = module.instance.image_catalog_resource_ver
}

output "lb_ip" {
  value = module.lb.lb_ip
}
