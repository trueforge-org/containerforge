# Docker Hub: victoriametrics/victoria-metrics

Source URL(s) + fetch date: https://hub.docker.com/r/victoriametrics/victoria-metrics · fetched 2026-11-26

## What it is
- Single-node VictoriaMetrics image, "a fast, cost-effective, scalable TSDB in one easy-to-deploy binary". Publisher: Victoria Metrics Inc (Verified Publisher). More than 100M pulls.

## Install/build steps
- `docker pull victoriametrics/victoria-metrics`
- Quick start: `docker run -d --name victoriametrics -p 8428:8428 victoriametrics/victoria-metrics:latest`
- Help: `docker run --rm victoriametrics/victoria-metrics:latest --help`

## Env vars
- None documented. Configuration via command-line flags.

## Ports
- 8428 (used in the quick start mapping).

## Volumes/paths and persistent data
- Mount a volume at `/victoria-metrics-data` and pass `-storageDataPath=/victoria-metrics-data` to keep data on the host.

## Flags shown
- `-storageDataPath` (default `victoria-metrics-data`), `-retentionPeriod` (default 1m, e.g. `3m` or `1y`), `-httpListenAddr` (default `:8428`).

## Version/release info
- Only `latest` tag shown (image size about 18.1 MB, updated 3 days before fetch). Tags tab exists but not listed.

## Arch support
- Not listed on the page.

## Gotchas
- Retention example `1m` on this page is "1 month". Plan uses the default `1M`; the page says `1m`, both mean one month in the docs, but the page does not state the unit semantics for bare numbers.
