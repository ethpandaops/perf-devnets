////////////////////////////////////////////////////////////////////////////////////////
//                                   DNS CONFIGURATION
////////////////////////////////////////////////////////////////////////////////////////

data "cloudflare_zone" "default" {
  name = "ethpandaops.io"
}

locals {
  # DNS records data extracted from inventory
  dns_hosts = {
    "bootnode-1" = {
      ipv4 = "37.27.123.80"
      ipv6 = "2a01:4f9:3070:2d51::2"
    }
    "lighthouse-nethermind-1" = {
      ipv4 = "37.27.130.157"
      ipv6 = "2a01:4f9:3071:129e::2"
    }
    "lighthouse-reth-1" = {
      ipv4 = "37.27.130.154"
      ipv6 = "2a01:4f9:3071:129b::2"
    }
    "nimbus-besu-1" = {
      ipv4 = "37.27.130.176"
      ipv6 = "2a01:4f9:3071:129f::2"
    }
    "prysm-geth-1" = {
      ipv4 = "65.109.121.144"
      ipv6 = "2a01:4f9:3051:1567::2"
    }
    "teku-erigon-1" = {
      ipv4 = "65.109.153.160"
      ipv6 = "2a01:4f9:3080:1096::2"
    }
  }

  # Generate DNS records for each host and subdomain
  dns_records = flatten([
    for hostname, ips in local.dns_hosts : [
      # Main hostname A and AAAA records
      {
        name    = "${hostname}.${var.ethereum_network}"
        type    = "A"
        content = ips.ipv4
      },
      {
        name    = "${hostname}.${var.ethereum_network}"
        type    = "AAAA"
        content = ips.ipv6
      },
      # Beacon node (bn) subdomain
      {
        name    = "bn.${hostname}.${var.ethereum_network}"
        type    = "A"
        content = ips.ipv4
      },
      {
        name    = "bn.${hostname}.${var.ethereum_network}"
        type    = "AAAA"
        content = ips.ipv6
      },
      # RPC subdomain
      {
        name    = "rpc.${hostname}.${var.ethereum_network}"
        type    = "A"
        content = ips.ipv4
      },
      {
        name    = "rpc.${hostname}.${var.ethereum_network}"
        type    = "AAAA"
        content = ips.ipv6
      }
    ]
  ])
}

# Create DNS records for static OVH hosts
resource "cloudflare_record" "ovh_static_hosts" {
  for_each = {
    for idx, record in local.dns_records : "${record.name}-${record.type}" => record
  }

  zone_id = data.cloudflare_zone.default.id
  name    = each.value.name
  value   = each.value.content
  type    = each.value.type
  ttl     = 120
  proxied = false
}