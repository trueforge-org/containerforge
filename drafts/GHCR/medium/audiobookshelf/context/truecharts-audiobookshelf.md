# TrueCharts chart: audiobookshelf

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/audiobookshelf/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `audiobookshelf` v15.0.0, `appVersion: 2.38.0`, category `media`, train `stable`.
- Description: "Audiobookshelf is a self-hosted audiobook server for managing and playing your audiobooks."
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: `ghcr.io/advplyr/audiobookshelf`, github advplyr/audiobookshelf, trueforge chart path.
- kubeVersion `>=1.33.0-0`; helm min 3.14; max k8s 1.35.0.

## Image (values.yaml)
- Repository: `ghcr.io/advplyr/audiobookshelf`
- Tag: `2.38.0@sha256:60064c23f32fd9099fd39e82c5132c51701d1221135bbca04cd099b589e1edc3`
- pullPolicy: IfNotPresent

## Security context (chart defaults)
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Ports
| Name | Service port | Target |
| --- | --- | --- |
| main | 10223 | (default) |

Chart sets env `PORT` to `service.main.ports.main.port` (10223).

## Probes (HTTP path `/ping`)
- liveness, readiness, startup: `path: "/ping"`.

## Env (workload.main.podSpec.containers.main.env)
| Var | Value |
| --- | --- |
| AUDIOBOOKSHELF_UID | `{{ .Values.securityContext.container.PUID }}` |
| AUDIOBOOKSHELF_GID | `{{ .Values.securityContext.pod.fsGroup }}` |
| PORT | `{{ .Values.service.main.ports.main.port }}` |
| TOKEN_SECRET | secretKeyRef `secrets`/`TOKEN_SECRET` |

- `audiobookshelf.tokenSecret`: placeholder `"PLACEHOLDERTOKENSECRETCHANGEME00"` ("Must be changed. Random string (32 characters recommended).")

## Persistence
| Name | Mount |
| --- | --- |
| config | /config |
| audiobooks | /audiobooks |
| metadata | /metadata |

## Resources
- limits cpu 500m / mem 750Mi; requests cpu 50m / mem 125Mi.

## Gotchas
- Chart uses `AUDIOBOOKSHELF_UID/GID` env vars (not present in upstream Dockerfile).
- Chart mounts `/metadata` separately; upstream Dockerfile sets `METADATA_PATH=/metadata`.
- Chart runs as root.
