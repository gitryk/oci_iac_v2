#provider
api_fingerprint      = ""
api_private_key_path = "./keys/terraform/private.pem"
region               = "ap-chuncheon-1"
region_ad            = "vkWn:AP-CHUNCHEON-1-AD-1"
tenancy_id           = ""
user_id              = ""

#app
project_name = ""
owner        = ""

#server
server_config = {
  main = { name = "gateway", vcpu = 1, storage = 50, ip = "172.16.30.10", os_image = "rocky" }
  sub  = { name = "central", vcpu = 3, storage = 150, ip = "172.16.30.11", os_image = "rocky" }
}

tailscale_authkey = ""

#network
vcn_cidr = ["172.16.30.0/27"]

network_config = {
  pub = { cidr = "172.16.30.16/28" }
  pri = { cidr = "172.16.30.0/28" }
}

nsg_rule = {
  "allow-ext-http"  = { type = "pub", min = 80, max = null, protocol = "tcp", direction = "INGRESS", target = "0.0.0.0/0", target_type = "CIDR_BLOCK", description = "Allow HTTP (EXT → LB)" },
  "allow-ext-https" = { type = "pub", min = 443, max = null, protocol = "tcp", direction = "INGRESS", target = "0.0.0.0/0", target_type = "CIDR_BLOCK", description = "Allow HTTPS/DoH (EXT → LB)" },
  "allow-ext-quic"  = { type = "pub", min = 443, max = null, protocol = "udp", direction = "INGRESS", target = "0.0.0.0/0", target_type = "CIDR_BLOCK", description = "Allow HTTPS/QUIC (EXT → LB)" },
  "allow-ext-wg"    = { type = "pub", min = 51820, max = null, protocol = "udp", direction = "INGRESS", target = "0.0.0.0/0", target_type = "CIDR_BLOCK", description = "Allow WireGuard (EXT → LB)" },
  "allow-lb-http"   = { type = "pri", min = 10080, max = null, protocol = "tcp", direction = "INGRESS", target = "pub", target_type = "NETWORK_SECURITY_GROUP", description = "Allow HTTP (LB → VM)" },
  "allow-lb-https"  = { type = "pri", min = 10443, max = null, protocol = "tcp", direction = "INGRESS", target = "pub", target_type = "NETWORK_SECURITY_GROUP", description = "Allow HTTPS (LB → VM)" },
  "allow-lb-quic"   = { type = "pri", min = 10444, max = null, protocol = "udp", direction = "INGRESS", target = "pub", target_type = "NETWORK_SECURITY_GROUP", description = "Allow HTTPS/QUIC (LB → VM)" },
  "allow-lb-wg"     = { type = "pri", min = 51820, max = null, protocol = "udp", direction = "INGRESS", target = "pub", target_type = "NETWORK_SECURITY_GROUP", description = "Allow WireGuard (LB → VM)" },
  "allow-pri-icmp"  = { type = "pri", min = null, max = null, protocol = "icmp", direction = "INGRESS", target = "pri", target_type = "NETWORK_SECURITY_GROUP", description = "Allow PriNet ICMP" },
  "allow-pri-tcp"   = { type = "pri", min = 1, max = 65535, protocol = "tcp", direction = "INGRESS", target = "pri", target_type = "NETWORK_SECURITY_GROUP", description = "Allow PriNet TCP" },
  "allow-pri-udp"   = { type = "pri", min = 1, max = 65535, protocol = "udp", direction = "INGRESS", target = "pri", target_type = "NETWORK_SECURITY_GROUP", description = "Allow PriNet UDP" },
  #"allow-tail-cnc"      = { type = "pri", min = 443, max = null, protocol = "tcp", direction = "EGRESS", target = "0.0.0.0/0", target_type = "CIDR_BLOCK", description = "Allow Tailscale Control Server (Bastion → Tailscale)" },
  #"allow-tail-derp-in"  = { type = "pri", min = 41641, max = null, protocol = "udp", direction = "INGRESS", target = "0.0.0.0/0", target_type = "CIDR_BLOCK", description = "Allow Tailscale DERP (Tailscale → Bastion)" },
  #"allow-tail-derp-out" = { type = "pri", min = 41641, max = null, protocol = "udp", direction = "EGRESS", target = "0.0.0.0/0", target_type = "CIDR_BLOCK", description = "Allow Tailscale DERP (Tailscale → Bastion)" },
} # rule for icmp, min is type, max is code and if type is null, allow all icmp
