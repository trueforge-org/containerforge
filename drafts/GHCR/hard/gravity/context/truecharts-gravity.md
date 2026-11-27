# TrueCharts: gravity (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gravity/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart `gravity` version 9.0.0, appVersion 0.34.0. Category dns. "Fully-replicated DNS and DHCP Server with ad-blocking powered by etcd."
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.
- Chart sources: ghcr.io/beryju/gravity, github.com/BeryJu/gravity.

## Image (values.yaml)
- repository: ghcr.io/beryju/gravity
- tag: `v0.34.0@sha256:477047a127d07a5c5d96691a668939e74ab7a348aa8e766b5ba9c35b30135acc`
- pullPolicy IfNotPresent.

## Env (workload.main containers.main)
| Name | Value / source |
| --- | --- |
| INSTANCE_IP | "127.0.0.1" |
| INSTANCE_LISTEN | "0.0.0.0" |
| INSTANCE_IDENTIFIER | "truecharts-dns-gravity" |
| BOOTSTRAP_ROLES | "dns;api;etcd;discovery;backup;monitoring;tsdb" |
| ADMIN_PASSWORD | secretKeyRef env-secrets/ADMIN_PASSWORD (chart default "password") |
| ADMIN_TOKEN | secretKeyRef gravity-secret/ADMIN_TOKEN |

## Chart-level values
- `gravity.adminToken`: placeholder "PLACEHOLDERADMINTOKEN0000000000000", comment says must be changed (random, >=32 chars). Chart creates secret `gravity-secret` from this (not verified in chart templates).
- secret env-secrets: ADMIN_PASSWORD "password" (default).

## Ports
| Name | Port | Target | Proto |
| --- | --- | --- | --- |
| main | 8008 | 8008 | http |
| dns-tcp | 53 | 53 | tcp |
| dns-udp | 53 | 53 | udp |

## Persistence
- data -> /data (enabled).

## Security
- runAsUser 0; runAsGroup 0.

## Gotchas
- Default ADMIN_PASSWORD "password" and placeholder admin token must be replaced.
- Port 53 requires root or NET_BIND_SERVICE; chart runs as root.
