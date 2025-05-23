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
      ipv4 = "141.94.98.35"
      ipv6 = "2001:41d0:303:fc23::"
    }
    "lodestar-reth-1" = {
      ipv4 = "51.79.163.221"
      ipv6 = "2402:1f00:8001:add::"
    }
    "nimbus-besu-1" = {
      ipv4 = "135.125.188.98"
      ipv6 = "2001:41d0:700:4f62::"
    }
    "prysm-geth-1" = {
      ipv4 = "51.222.244.145"
      ipv6 = "2607:5300:203:8d91::"
    }
    "teku-erigon-1" = {
      ipv4 = "148.113.0.155"
      ipv6 = "2402:1f00:8300:9b::"
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