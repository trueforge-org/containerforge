# TrueCharts nebula-sync (chart 3.0.0, appVersion 0.11.3)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nebula-sync/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "Synchronize Pi-hole v6.x configuration to replicas."
- Chart sources: ghcr.io/lovelaze/nebula-sync, github.com/lovelaze/nebula-sync (trueforge tree link).
- Category networking, train stable, not deprecated. Keywords: pihole, sync, adblocking.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/lovelaze/nebula-sync |
| Tag | v0.11.3 (digest pinned) |
| Pull policy | IfNotPresent |

## Ports / probes
- Service main port 8080. Container port not specified in values.
- liveness, startup, readiness: path `/health` (port not specified).

## Env vars (chart values, container main)
| Var | Chart value |
| --- | --- |
| PRIMARY | `pi.hole\|password` (placeholder) |
| REPLICAS | `pi2.hole\|password` (placeholder) |
| FULL_SYNC | false |
| RUN_GRAVITY | false |
| CLIENT_SKIP_TLS_VERIFICATION | true |
| CRON | `*/15 * * * *` |
| SYNC_CONFIG_DNS | true |
| SYNC_CONFIG_DHCP / _NTP / _RESOLVER / _DATABASE / _MISC / _DEBUG | false |
| SYNC_CONFIG_DNS_EXCLUDE | upstreams |
| SYNC_GRAVITY_DHCP_LEASES | false |
| SYNC_GRAVITY_GROUP | false |
| SYNC_GRAVITY_AD_LIST | true |
| SYNC_GRAVITY_AD_LIST_BY_GROUP | true |
| SYNC_GRAVITY_DOMAIN_LIST | true |
| SYNC_GRAVITY_DOMAIN_LIST_BY_GROUP | true |
| SYNC_GRAVITY_CLIENT | false |
| SYNC_GRAVITY_CLIENT_BY_GROUP | false |

## Persistence / paths / securityContext
- No persistence mounts defined.
- No securityContext defined.
- No secretKeyRef/configMapKeyRef: credentials are inline in PRIMARY/REPLICAS.

## Gotchas
- Chart comment: upstream DNS servers are set in env by the TrueCharts Pi-hole chart and cannot be overwritten, hence SYNC_CONFIG_DNS_EXCLUDE=upstreams.
- See upstream-nebula-sync-dockerfile.md for the image's USER 1001 and healthcheck.
