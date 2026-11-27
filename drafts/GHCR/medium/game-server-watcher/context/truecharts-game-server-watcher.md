# TrueCharts chart: game-server-watcher

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/game-server-watcher/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/game-server-watcher/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `game-server-watcher` version 7.0.0, `appVersion: 3.1.26`, train `stable`, category `monitor`.
- Description: "A simple discord/telegram/slack bot to monitor your game servers and players in style."
- Sources listed: `ghcr.io/a-sync/game-server-watcher`, `github.com/a-sync/game-server-watcher`.

## Image
- `repository: ghcr.io/a-sync/game-server-watcher`
- `tag: v3.1.26@sha256:5cb29907003a64021271aa3e553f40eaf59d71a961bdc9108bdc2e2dc3645467`
- `pullPolicy: IfNotPresent`

## Runtime deps (chart common)
- `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`

## Env vars (chart `workload.main.podSpec.containers.main.env`)
| Name | Chart value | Source |
| --- | --- | --- |
| DATA_PATH | `{{.Values.persistence.data.mountPath}}` (`/data`) | literal template |
| HOST | `0.0.0.0` | literal |
| PORT | `{{ .Values.service.main.ports.main.port }}` (= 10690) | template |
| SECRET | secretKeyRef `env-secrets`/`SECRET` | secret |
| DBG | `0` | literal |
| REFRESH_TIME_MINUTES | `2` | literal |
| STEAM_WEB_API_KEY | secretKeyRef `env-secrets`/`STEAM_WEB_API_KEY` | secret |
| DISCORD_BOT_TOKEN | secretKeyRef `env-secrets`/`DISCORD_BOT_TOKEN` | secret |
| TELEGRAM_BOT_TOKEN | secretKeyRef `env-secrets`/`TELEGRAM_BOT_TOKEN` | secret |
| SLACK_BOT_TOKEN | secretKeyRef `env-secrets`/`SLACK_BOT_TOKEN` | secret |
| SLACK_APP_TOKEN | secretKeyRef `env-secrets`/`SLACK_APP_TOKEN` | secret |

## Ports
- Service `main`, port `main`: protocol http, **port 10690** (chart value). Upstream default is 8080 (see GitHub file). The chart overrides it through `PORT`.

## Volumes/paths
- `persistence.data`: enabled, `mountPath: /data`.

## User/UID
- Chart: `securityContext.container.runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. Chart runs as root.

## Config files
- None in the chart. Secrets are created as `env-secrets` with keys SECRET (default `secret`), STEAM_WEB_API_KEY, DISCORD_BOT_TOKEN, TELEGRAM_BOT_TOKEN, SLACK_BOT_TOKEN, SLACK_APP_TOKEN (all empty by default except SECRET).

## Healthcheck
- Not set in chart.

## Gotchas
- Chart pins `PORT` to 10690 while upstream `EXPOSE 8080` and README use 8080.
- Chart image tag has the `v` prefix (`v3.1.26`).
