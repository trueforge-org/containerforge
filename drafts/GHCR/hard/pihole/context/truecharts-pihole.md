# TrueCharts chart: pihole

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pihole/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `pihole` v24.0.0, appVersion 2026.11.0, train stable, category networking.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image
- repository: `ghcr.io/pi-hole/pihole`
- tag: `2026.11.0@sha256:66c798d7...a52778` (pullPolicy IfNotPresent)

## Ports
| name | port | target | proto |
| --- | --- | --- | --- |
| main (web) | 9089 | 80 | tcp |
| dns | 53 | 53 | udp |
| dns-tcp | 53 | 53 | tcp |

## Env (chart-set)
| var | value |
| --- | --- |
| PIHOLE_UID | `{{ .Values.securityContext.container.PUID }}` (key not defined in values: empty) |
| PIHOLE_GID | `{{ .Values.securityContext.pod.fsGroup }}` |
| FTLCONF_dns_upstreams | `8.8.8.8;8.8.4.4` |
| FTLCONF_webserver_api_password | secretKeyRef `env-secrets` / `FTLCONF_webserver_api_password` |

## Secret
- `env-secrets` with placeholder `FTLCONF_webserver_api_password: "somepassword"`.

## Probes
- liveness, readiness, startup: HTTP GET `/admin`.

## Persistence
| name | mountPath |
| --- | --- |
| config | /etc/pihole |
| dnsmasq | /etc/dnsmasq.d |

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, allowPrivilegeEscalation true.
- capabilities add: NET_ADMIN, SETFCAP, SETPCAP, KILL, SYS_TIME, SYS_NICE.

## Gotchas
- PIHOLE_UID references `.Values.securityContext.container.PUID`, which is not set in values.
- Chart runs as root; image upstream runs as root and drops to `pihole`.
