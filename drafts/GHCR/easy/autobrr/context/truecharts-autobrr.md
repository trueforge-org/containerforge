# TrueCharts chart: autobrr (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/autobrr/values.yaml , .../Chart.yaml

## What it is
- Chart `autobrr` version 14.0.0, appVersion 1.91.1, description "The modern download automation tool for torrents."
- Sources: https://ghcr.io/autobrr/autobrr , https://github.com/autobrr/autobrr

## Image (values.yaml)
- repository `ghcr.io/autobrr/autobrr`
- tag `v1.91.1@sha256:8c63fa0ba732eb33b2e531a84b3de3c99ae88e87c49bf077a6194020667ef92f`

## Service / port
- main: port 7474, protocol http

## Config values
- `autobrr.log_level`: DEBUG (chart default)
- `autobrr.sessionSecret`: placeholder "PLACEHOLDERSESSIONSECRETCHANGEME" (must change, 32 chars recommended)

## Probes
- liveness http, readiness http, startup tcp (no paths given)

## Persistence
- `config` enabled, mountPath `/config`
- `autobrr-config` secret `autobrr-config` mounted read-only at `/config/config.toml` (subPath config.toml)

## Gotchas
- Chart mounts config.toml as a secret file under /config
- Chart sets `log_level` and `sessionSecret` as chart values (not env names)
