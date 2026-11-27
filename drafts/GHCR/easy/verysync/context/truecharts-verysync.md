# TrueCharts chart: verysync

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/verysync/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `verysync` v15.0.0, appVersion 2.33.2. Description: multi-platform file synchronization (P2P). Category media.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/jonnyan404/verysync`
- tag: `v2.33.2@sha256:6ef12fb4228ac83e165a466df7f7b20af1f1e6cc5ebdb5a724534c84a26748d6`
- pullPolicy: IfNotPresent

## Runtime security
- runAsUser 0, runAsGroup 0 (required: entrypoint exits if not root)

## Ports
| name | port | protocol | enabled |
| --- | --- | --- | --- |
| main | 10193 | (default, web GUI) | yes |
| bt-udp1 | 22037 | udp | yes |
| bt-udp2 | 22027 | udp | yes |
| data | 22330 | (default) | yes |

## Persistence
| name | mountPath |
| --- | --- |
| data | /data |
| sync | /Sync |

## Env vars (chart values)
| Env | Value |
| --- | --- |
| PORT | "{{ .Values.service.main.ports.main.port }}" (10193) |
| VUID | "{{- $.Values.securityContext.container.PUID -}}" (PUID not defined in chart values; see gotchas) |

## Gotchas
- Upstream image PORT default is 8886; chart overrides to 10193 via PORT env.
- VUID template references `securityContext.container.PUID`, which is not set in values.yaml. Rendered value unverified; if empty the entrypoint runs verysync as root (no gosu).
- No probes in values.yaml (upstream Dockerfile has HEALTHCHECK `nc -z 127.0.0.1 ${PORT}`).
