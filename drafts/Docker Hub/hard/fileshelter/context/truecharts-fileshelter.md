# TrueCharts chart: fileshelter

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fileshelter (chart values via raw `values.yaml`, fetched 2026-11-26)

## Image

- `repository`: `docker.io/epoupon/fileshelter`
- `tag`: `6.4.0@sha256:6524840f2501d8e5362200c4bf4379d6f84416211d37900171d111110c77e83a`
- `pullPolicy`: `IfNotPresent`

## Security

- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. `privileged` not set.

## Persistence

- `config` -> `/var/fileshelter`, enabled. No `type` given.

## Ports

- service `main` port `5091` -> targetPort `5091`.

## Env and probes

- No env entries; no probes specified.

## Gotchas

- The chart uses `/var/fileshelter` (upstream working dir). Plan moves data to `/config` via the seeded config.
