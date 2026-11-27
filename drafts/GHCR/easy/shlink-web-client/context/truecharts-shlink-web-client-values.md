# TrueCharts shlink-web-client values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink-web-client/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/shlinkio/shlink-web-client`
- tag: `4.9.1@sha256:732c291bcc099d6ff51038bcfba374be87494fa2916683a44d3135ea57cbe935`
- pullPolicy: IfNotPresent

## Ports
- service main: port `10154` → targetPort `8080` (http)

## Env vars (main container)
- SHLINK_SERVER_URL: `""`
- SHLINK_SERVER_NAME: `""`
- SHLINK_SERVER_API_KEY: secretKeyRef `env-secrets` / `SHLINK_SERVER_API_KEY`

Secret `env-secrets` enabled, SHLINK_SERVER_API_KEY `""`.

## Volumes/paths
- none defined

## User/UID, probes, securityContext
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, fsGroup not set (chart overrides image's non-root default)
- No probes.

## Gotchas
- Chart env names match the upstream env-based servers.json generation (SHLINK_SERVER_URL / API_KEY / NAME).
