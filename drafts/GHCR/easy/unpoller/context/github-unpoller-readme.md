# Upstream README: unpoller/unpoller

Source URL(s) + date: https://raw.githubusercontent.com/unpoller/unpoller/master/README.md (fetched 2026-11-27)

## What it is
- UnPoller: small Go app that polls a UniFi controller and exports to InfluxDB (every 30s), Prometheus (web port, /metrics), Loki (events/alarms/IDS), or Datadog (per example config).
- Supports UniFi controllers, UDM, USG/USW/UAP devices.
- Ships 12-13 Grafana dashboards (6 Influx, 6-7 Prometheus).
- Legacy names: github.com/unifi-poller/unifi-poller (redirect/alias).

## Install / run
- Packages for macOS, Linux, FreeBSD, Docker, Windows. Docker image `golift/unifi-poller` (Docker Hub, legacy) and GHCR per chart.
- Documentation at https://unpoller.com (not fetched).

## Runtime deps
- A running UniFi controller (must be reachable all the time).

## Config
- Primary config file is TOML (up.conf). See github-unpoller-example-config.md.
- Env var overrides exist (examples: UP_PROMETHEUS_INTERVAL, UP_PROMETHEUS_DISABLE, UP_UNIFI_DEFAULT_*) per example config comments.

## Gotchas
- Copyright listed as 2018-2020 in README; license per LICENSE file (not fetched).
