# TrueCharts gonic (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gonic/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gonic/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `gonic` v19.0.0, appVersion 0.23.0. Keywords: music, subsonic.
- Depends on `common` (library).
- Chart sources: ghcr.io/sentriz/gonic, github.com/sentriz/gonic.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/sentriz/gonic` |
| tag | `v0.23.0@sha256:7b2298d905149ecb7e57cdd3bf7a40082758b9bda2e24454b41c17c99bf25e8f` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Ports

| Name | Container port | Service port |
| --- | --- | --- |
| main | from `GONIC_LISTEN_ADDR` (`:10023`) | 10023 |

## Env (chart-provided)

| Var | Value |
| --- | --- |
| GONIC_LISTEN_ADDR | `:{{ service.main.ports.main.port }}` (= `:10023`) |
| GONIC_DB_PATH | `{{ data mountPath }}/gonic.db` (= `/data/gonic.db`) |
| GONIC_CACHE_PATH | `{{ cache mountPath }}` (= `/cache`) |
| GONIC_PLAYLISTS_PATH | `{{ playlists mountPath }}` (= `/playlists`) |
| GONIC_PODCAST_PATH | `{{ podcast mountPath }}` (= `/podcast`) |
| GONIC_MUSIC_PATH | `{{ music mountPath }}` (= `/music`) |

## Volumes / paths

| Name | Mount | Enabled |
| --- | --- | --- |
| data | `/data` | yes |
| cache | `/cache` | yes |
| playlists | `/playlists` | yes |
| podcast | `/podcast` | yes |
| music | `/music` | yes |

- Note: chart mounts podcast at `/podcast`; upstream image default is `/podcasts`.

## User / UID

- `securityContext.container`: `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Healthcheck / probes

- None set in values.yaml.

## Gotchas

- Chart runs as root; ContainerForge plan runs non-root.
- Chart uses 5 persistent paths; plan maps all to `/config/*` except music.
