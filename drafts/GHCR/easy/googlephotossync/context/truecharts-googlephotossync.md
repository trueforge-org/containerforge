# TrueCharts googlephotossync (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/googlephotossync/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/googlephotossync/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `googlephotossync` v12.0.0, appVersion 3.2.5.
- Description: downloads Google Photos to local FS (photos, videos, albums, Creations).
- Category: Other. Depends on `common` (library).
- Chart sources: ghcr.io/gilesknap/gphotos-sync.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/gilesknap/gphotos-sync` |
| tag | `3.2.5@sha256:bd89d1998f932eaa976df171ae2f8d707263a64c75f3676ec2759f1c878abb8e` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Ports / service

- `service.main.enabled: false`, `ports.main.enabled: false`. No port exposed.

## Volumes / paths

| Name | Mount | Enabled |
| --- | --- | --- |
| config | `/config` | yes |
| data | `/storage` | yes |

## User / UID

- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Healthcheck / probes

- liveness, readiness, startup all `enabled: false`.

## Env

- No env vars set in values.yaml.
