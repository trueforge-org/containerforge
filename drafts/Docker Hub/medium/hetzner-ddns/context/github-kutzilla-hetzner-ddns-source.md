# kutzilla/docker-hetzner-ddns: Go source (commit 511c911, key constants)
Source URL(s): raw.githubusercontent.com/kutzilla/docker-hetzner-ddns/511c911/pkg/dns/hetzner.go, pkg/ip/ipify.go, pkg/conf/conf.go (fetched 2026-11-26; tree from api.github.com git/trees 511c911 recursive)

## Repo layout
cmd/hetzner-ddns/main.go; pkg/conf; pkg/ddns (ddns.go, sheduler.go); pkg/dns (dns.go, hetzner.go); pkg/ip (ip.go, ipify.go); .github workflows.

## hetzner.go
- HetznerHost = "dns.hetzner.com" (https)
- Zones path: api/v1/zones ; records path: api/v1/records (?zone_id=)
- Auth header: Auth-API-Token

## ipify.go
- api.ipify.org (IPv4), api64.ipify.org (IPv6), https

## conf.go (env names)
ZONE_NAME, API_TOKEN, RECORD_TYPE, RECORD_NAME (prefix for RECORD_NAME_<NAME>, <NAME>_TTL), CRON_EXPRESSION, TTL
- Defaults: record name "@", type "A", cron "*/5 * * * *", TTL 86400
- Uses github.com/namsral/flag (env vars also accepted as CLI flags)

## Gotchas
- Entire upstream API target is dns.hetzner.com, which is shut down (see hetzner-dns-endpoint.md and hetzner-status-incident.md). Image will not update records.
