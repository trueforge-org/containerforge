# TrueCharts chart: watchyourlan

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/watchyourlan/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/aceberg/watchyourlan` (LAN IP scanner with web GUI).
- Chart `version: 15.0.0`, `appVersion: 2.1.4`, category network, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Chart dependency: `postgresql` (enabled, depconfig user/db `watchyourlan`).
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/aceberg/watchyourlan`, `tag: 2.1.4@sha256:f77532ca...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Note |
| --- | --- | --- |
| main | 10355 | protocol http; chart sets env PORT to this |

## Env vars (chart)
| Var | Value |
| --- | --- |
| PORT | {{ service.main.ports.main.port }} (10355) |
| PG_CONNECT | secret `env-secrets`, built as `postgres://watchyourlan:<pw>@<host>:5432/watchyourlan` |
| USE_DB | postgres |
| HOST | {{ watchyourlan.gui_ip }} ("0.0.0.0") |
| IFACES | space-joined `watchyourlan.interfaces` (default `enp1s0`) |
| THEME | sand |
| TIMEOUT | 120 |
| SHOUTRRR_URL | "" |

## Pod/network
- `podOptions.hostNetwork: true`.
- Container capabilities: add `NET_RAW`.

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| data | /data | enabled |

## Probes
- liveness, readiness, startup: all `type: http`, path `/`.

## User/UID
- `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Gotchas
- Chart sets `USE_DB: postgres`; upstream default is sqlite.
- `hostNetwork: true` required by upstream for ARP scanning.
- Chart comment says PG_CONNECT format unsure.
