# TrueCharts prometheus-pve-exporter chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/prometheus-pve-exporter/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/prometheus-pve-exporter/Chart.yaml
- Fetched 2026-11-27

## What it is
- "A Prometheus exporter for Proxmox Virtual Environment metrics." Chart 5.0.0, appVersion 3.12.0, keywords monitoring/proxmox
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/prometheus-pve/prometheus-pve-exporter, github prometheus-pve/prometheus-pve-exporter, Grafana dashboard 10347

## Image (values.yaml)
- repository: `ghcr.io/prometheus-pve/prometheus-pve-exporter` (GHCR, no Docker Hub source)
- tag: `3.12.0@sha256:e49466559449074596e762dd09c9a76c9be9b6a1ffacf7bc8ceb827169cb180e`

## Service
| Service | Port | Proto |
| --- | --- | --- |
| main | 9221 | http |

## Chart values (pve.*)
| Key | Default |
| --- | --- |
| pve.credentials.user | username@realm |
| pve.credentials.tokenName | your-token-name |
| pve.credentials.tokenValue | your-token-value (token role PVEAuditor) |
| pve.general.target | pve.example.com |
| pve.general.verifySsl | true |

## Env / args (workload.main)
| Name | Value |
| --- | --- |
| PVE_VERIFY_SSL | from pve.general.verifySsl |
| PVE_USER | from pve.credentials.user |
| PVE_TOKEN_NAME | from pve.credentials.tokenName |
| PVE_TOKEN_VALUE | secret `credentials` (envFrom secretRef) |

- args: `--web.listen-address :9221`
- Optional commented args: `--no-collector.status|version|node|cluster|resources|config`

## Secrets
- secret `credentials`: PVE_TOKEN_VALUE = pve.credentials.tokenValue

## Metrics
- ServiceMonitor enabled, endpoint port `main`, path `/pve`, param `target` = pve.general.target, relabel `instance` = target

## Dashboard
- configmap `dashboard` with label grafana_dashboard "1", file `dashboard.json` (chart file)

## Probes / persistence / user
- No probes, persistence, or securityContext overrides in values (chart defaults apply)

## Gotchas
- Token role must be PVEAuditor on Proxmox VE.
- Chart values carry placeholder credentials (username@realm, your-token-value).
