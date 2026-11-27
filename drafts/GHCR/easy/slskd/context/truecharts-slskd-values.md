# TrueCharts slskd values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slskd/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/slskd/slskd`
- tag: `0.26.2@sha256:d0963a3e5b16facd295bf4f2156dad0182f246b1b21a032cae12f5494c694843`
- pullPolicy: IfNotPresent

## Ports
- service main port 5030 (protocol not stated)
- Env sets SLSKD_SLSK_LISTEN_PORT and SLSKD_HTTP_PORT to 5030 (chart value); commented alt Soulseek port settings

## Env vars (main container)
- SLSKD_SLSK_LISTEN_IP_ADDRESS `0.0.0.0`
- SLSKD_SLSK_LISTEN_PORT `5030` (from chart port value)
- SLSKD_HTTP_PORT `5030`
- APP_DIR `/app` (persistence data mountPath)
- SLSKD_SHARED_DIR → share mountPath `/share`
- SLSKD_DOWNLOADS_DIR → complete mountPath `/downloads/complete`
- SLSKD_INCOMPLETE_DIR → incomplete mountPath `/downloads/incomplete`
- SLSKD_USERNAME `admin`
- SLSKD_PASSWORD: secretKeyRef `env-secrets` / `SLSKD_PASSWORD` (chart default value `admin123`)
- SLSKD_JWT_KEY: secretKeyRef `slskd-secrets` / `SLSKD_JWT_KEY` (placeholder; min 16 chars, 64 recommended)

## Volumes/paths (all enabled)
- data `/app`, share `/share`, incomplete `/downloads/incomplete`, complete `/downloads/complete`

## User/UID, probes, securityContext
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, fsGroup not set (chart runs as root)
- No probes defined.

## Gotchas
- Chart uses `APP_DIR` as the env name; upstream Dockerfile sets `SLSKD_APP_DIR`.
- Chart sets SLSKD_SLSK_LISTEN_PORT to the HTTP port value (5030), which differs from the upstream default 50300.
