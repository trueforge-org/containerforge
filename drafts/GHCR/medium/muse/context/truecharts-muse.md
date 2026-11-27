# TrueCharts chart: muse

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/muse/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `muse` v11.0.0, appVersion 2.12.0. Discord music bot ("midwestern self-hosted").
- Deps: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources listed: ghcr.io/museofficial/muse, github.com/museofficial/muse.

## Image
- repository: `ghcr.io/museofficial/muse`
- tag: `2.12.0@sha256:b10ea1d4807ef62260947de1d9527b1bb909acb1818b838d0768734b3f5e2665`
- pullPolicy: IfNotPresent

## Security context (chart)
- container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (runs as root in chart)

## Service / probes
- service.main.enabled: false (no Service, no ports)
- liveness, readiness, startup probes: all disabled

## Env (chart workload.main.podSpec.containers.main.env)
| Env | Value in chart |
| --- | --- |
| DATA_DIR | `{{ persistence.config.mountPath }}` (= /config) |
| DISCORD_TOKEN | secretKeyRef env-secrets/DISCORD_TOKEN |
| SPOTIFY_CLIENT_ID | `{{ muse.spotify.client.id }}` |
| SPOTIFY_CLIENT_SECRET | secretKeyRef env-secrets/SPOTIFY_CLIENT_SECRET |
| YOUTUBE_API_KEY | secretKeyRef env-secrets/YOUTUBE_API_KEY |
| BOT_STATUS | `{{ muse.bot.status }}` (default "online") |
| BOT_ACTIVITY_TYPE | `{{ muse.bot.activity.type }}` (default PLAYING) |
| BOT_ACTIVITY | `{{ muse.bot.activity.detail }}` (default "A helm chart") |
| BOT_ACTIVITY_URL | `{{ muse.bot.activity.url }}` |
| REGISTER_COMMANDS_ON_BOT | `{{ muse.bot.register_commands }}` (default false) |
| CACHE_LIMIT | `{{ muse.cache.limit }}` (default 2GB) |

## Persistence
- `persistence.config`: enabled, mountPath `/config`

## Secrets
- secret `env-secrets`: DISCORD_TOKEN, SPOTIFY_CLIENT_SECRET, YOUTUBE_API_KEY (from values muse.*)

## Gotchas
- Chart mounts data at /config while Dockerfile default DATA_DIR is /data; chart overrides DATA_DIR=/config.
