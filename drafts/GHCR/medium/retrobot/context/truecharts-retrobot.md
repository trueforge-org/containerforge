# TrueCharts chart: retrobot (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/retrobot/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `retrobot` v14.0.0, appVersion `latest`, category emulator, depends on `common` 32.8.5.
- Description: Discord bot to play old Nintendo games with friends over chat.
- Sources: https://ghcr.io/rossimo/retrobot , https://github.com/rossimo/retrobot

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/rossimo/retrobot |
| tag | latest@sha256:63f85467247ea30ee18f92d2848423c4b084cd5fd524e622506e790c7148cfea |
| pullPolicy | IfNotPresent |

## Service
- `main` disabled (no ports).

## Persistence
- `data`: enabled, mountPath `/retrobot/data`

## Container env (chart override)
| Name | Value |
| --- | --- |
| MAX_WORKERS | -1 |
| MAX_WORKERS_PER_GAME | 3 |
| RECORDING_FRAMERATE | 30 |
| DISCORD_TOKEN | secretKeyRef env-secrets/DISCORD_TOKEN |

Secret `env-secrets` (enabled) with key `DISCORD_TOKEN: ''`.

## Probes
- liveness, readiness, startup: all disabled.

## Notes
- No security context override in values.yaml.
