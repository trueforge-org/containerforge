# TrueCharts chart: vocechat-server

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vocechat-server (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/privoce/vocechat-server`, tag `v0.5.41@sha256:729a6a96...` (truncated), pullPolicy `IfNotPresent`.

## Security context
- Not specified in values.yaml (no runAsUser, runAsGroup or readOnlyRootFilesystem set here; plan.md says the chart runs as UID 568 by default).

## Env vars
- None defined.

## Ports
- Service main, port 3009 (http), mapped to container 3000 via `--network.bind 0.0.0.0:<port>`. Upstream default is 3000.

## Args
- `--network.bind 0.0.0.0:{{ .Values.service.main.ports.main.port }}`
- `--network.frontend_url {{ .Values.vocechat.frontend_url }}` (chart value `vocechat.frontend_url` defaults to `localhost:3009`).

## Volumes/paths and persistent data
- `data` persistence, mounted at `/home/vocechat-server/data`.

## Healthcheck
- None defined.

## Gotchas
- The chart's CLI flag for the public URL is `--network.frontend_url`, not `--network.domain` as plan.md section 7 and section 6 assume. Flagged in README.md.
- The chart passes `--network.bind` explicitly; plan.md's start.sh relies on the default bind, which is also `0.0.0.0:3000` per plan.md.
