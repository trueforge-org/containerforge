# TrueCharts authentik (chart 43.0.8)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/authentik/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart `authentik` 43.0.8, appVersion **2026.8.7**, train stable, common 32.8.5.
- Description: open-source Identity Provider.
- Chart sources: ghcr.io/goauthentik/{ldap,proxy,radius,server}, ghcr.io/kiwigrid/k8s-sidecar, ghcr.io/maxmind/geoipupdate, github goauthentik/authentik, goauthentik.io/docs.

## Images (chart)
| Role | Repository | Tag (digest pinned) |
| --- | --- | --- |
| image (server) | ghcr.io/goauthentik/server | 2026.8.7 |
| geoipImage | ghcr.io/maxmind/geoipupdate | v8.0.0 |
| ldapImage | ghcr.io/goauthentik/ldap | 2026.8.7 |
| radiusImage | ghcr.io/goauthentik/radius | 2026.8.7 |
| proxyImage | ghcr.io/goauthentik/proxy | 2026.8.7 |
| sidecarImage | ghcr.io/kiwigrid/k8s-sidecar | 2.14.3 |

## Workloads (chart)
| Workload | args | Probes (exec) | runAs |
| --- | --- | --- | --- |
| main (server) | `server` | `/lifecycle/ak healthcheck` | 1000:1000 |
| worker | `worker` | `/lifecycle/ak healthcheck` | 1000:1000 |
| worker.blueprints (sidecar) | - | disabled | k8s-sidecar, watches `authentik_blueprint` label |
| proxy | - | `/authentik healthcheck proxy` | 1000:1000 |
| radius | - | `/radius healthcheck` | 1000:1000 |
| ldap | - | `/ldap healthcheck` | 1000:1000 |
| geoip | - | none | runAsUser 0 (geoipupdate) |

- Chart envFrom: configMap/secret `server`, `server-worker`, `worker`, `proxy`, `radius`, `ldap`, `geoip`.

## Ports (service)
| Name | Protocol | Port |
| --- | --- | --- |
| main | https | 10229 |
| http | http | 10230 (ClusterIP) |
| proxy http / https | http / https | 10227 / 10228 |
| radius | - | (port not read) |

## Secrets / config (values)
- authentik.secretKey: placeholder, must be changed (32+ chars).
- authentik.credentials: email, password (initial install only), optional bootstrapToken.
- general: disableStartupAnalytics true, gdprCompliance true, tokenLength 128, impersonation true, avatars gravatar/initials.
- logging.logLevel: info. errorReporting.enabled: false.
- geoip: enabled false, editionID GeoLite2-City, accountID/licenseKey empty.
- outposts (proxy, radius, ldap): enabled false, token empty.
- email: host "", port 587, useTLS true.

## Persistence
- blueprints mountPath is templated (`persistence.blueprints.targetSelector.worker.blueprints.mountPath`), path not read.

## Gotchas
- Chart runs server, worker, proxy, radius and ldap as UID 1000 (matches upstream `USER 1000`).
- Chart appVersion 2026.8.7 differs from the plan's build version 2026.8.6 (see README).
