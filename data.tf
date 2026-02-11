data "sops_file" "secret" {
  source_file = "./keys/secret.enc.json"
}
