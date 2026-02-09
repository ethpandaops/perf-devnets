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
      ipv4 = "157.180.14.229"
      ipv6 = "2a01:4f9:3100:37a3::2"
    }
    "lighthouse-geth-1" = {
      ipv4 = "206.189.58.47"
      ipv6 = "2a03:b0c0:3:f0:0:1:6f7d:9000"
    }
    "lighthouse-nethermind-1" = {
      ipv4 = "157.180.14.230"
      ipv6 = "2a01:4f9:3100:37aa::2"
    }
    "lighthouse-reth-1" = {
      ipv4 = "157.180.14.227"
      ipv6 = "2a01:4f9:3100:37a0::2"
    }
    "nimbus-besu-1" = {
      ipv4 = "157.180.14.226"
      ipv6 = "2a01:4f9:3100:37af::2"
    }
    "prysm-geth-1" = {
      ipv4 = "157.180.14.225"
      ipv6 = "2a01:4f9:3100:379f::2"
    }
    "teku-erigon-1" = {
      ipv4 = "157.180.14.228"
      ipv6 = "2a01:4f9:3100:37a1::2"
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