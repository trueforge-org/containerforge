# TrueCharts chart: wyoming-openwakeword

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wyoming-openwakeword (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/rhasspy/wyoming-openwakeword`, tag `2.1.0@sha256:52cb1168...` (truncated), pullPolicy `IfNotPresent`.

## App settings (chart values)
- `model` `ok_nabu`; `preload_model` `true`; `custom_model` path `""`; `threshold` `0.5`; `trigger_level` `1`; `debug` `false`.
- Mapping to CLI or env is not in the fetched values file. Per the code, `preload_model` has no effect in v2.1.0.

## Ports
- Service main port 10400 tcp.

## Security context, env, persistence, probes, args
- Not present in the fetched values file (no securityContext, no env, no persistence, no probes, no args).

## Gotchas
- Chart app settings are not wired to real flags in the fetched content.
