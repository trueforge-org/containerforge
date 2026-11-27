# TrueCharts kiwix-serve (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kiwix-serve/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kiwix-serve/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `kiwix-serve` v14.0.0, appVersion 3.8.2. "Kiwix enables you to have the whole Wikipedia at hand wherever you go!"
- Category: Productivity. Depends on `common`.
- Chart sources: ghcr.io/kiwix/kiwix-serve, github.com/kiwix/kiwix-tools (docker/server), kiwix.org.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/kiwix/kiwix-serve` |
| tag | `3.8.2@sha256:e478554a9920412eeb5ce1d73f24e4b28445ebed233187cdd03c623c32be46a5` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Ports

| Name | Port | Protocol |
| --- | --- | --- |
| main | 10323 | http |

- `PORT` env = service port.

## Env (chart-provided)

| Var | Value |
| --- | --- |
| DOWNLOAD | `http://download.kiwix.org/zim/wikipedia_en_chemistry_nopic.zim` |
| PORT | `{{ service.main.ports.main.port }}` (10323) |

## Args (chart)

- `args: ["*.zim"]` (serve all ZIM files in /data).

## Volumes / paths

| Name | Mount |
| --- | --- |
| data | `/data` (enabled) |

## User / UID

- `securityContext.container`: `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Healthcheck / probes

- None set in values.yaml.

## Gotchas

- Chart downloads a default ZIM (wikipedia chemistry, nopic) via DOWNLOAD.
- Chart runs as root; upstream image runs as uid 1001.
