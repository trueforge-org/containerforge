# TrueCharts backrest (stable chart v4.0.0, appVersion 1.14.1)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/backrest/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/backrest/Chart.yaml (fetched 2026-11-27)

## What it is
- "Web-accessible backup solution built on top of restic." Category: backup.
- Chart sources: ghcr.io/garethgeorge/backrest, github.com/garethgeorge/backrest.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- repository: `ghcr.io/garethgeorge/backrest`
- tag: `v1.14.1@sha256:b852979754281026230cc69fb11428e6d57c9a97784ab4a444ffc7934c53a215`
- pullPolicy: IfNotPresent

## Env vars (chart)
| Name | Value |
| --- | --- |
| BACKREST_PORT | `0.0.0.0:{{ service.main.ports.main.port }}` (i.e. 0.0.0.0:9898) |
| BACKREST_DATA | /data |
| BACKREST_CONFIG | /config/config.json |
| XDG_CACHE_HOME | /cache |
| TMPDIR | /tmp |

## Ports
- main: 9898 (service port and targetPort).

## Volumes/paths (persistence)
| Name | Mount | Type |
| --- | --- | --- |
| data | /data | PVC |
| config | /config | PVC |
| cache | /cache | PVC |
| tmp | /tmp | emptyDir |
| userdata | /userdata (readOnly, disabled by default) | - |

## Healthcheck
- Not set in values (no probe overrides).

## Gotchas
- Chart sets BACKREST_PORT to bind 0.0.0.0 explicitly (listen address is not otherwise confirmed by docs).
- Chart uses env names BACKREST_DATA / BACKREST_CONFIG; the upstream docs page does not document them (see backrest-docs.md).
