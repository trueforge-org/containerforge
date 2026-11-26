# TrueCharts chart: flextv

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flextv (values via raw `master/charts/stable/flextv/values.yaml`)

## Image

- `repository`: `docker.io/jcreynolds/flextv`
- `tag`: `latest@sha256:5a322ebf61462ab66188cee1fd110b4b8b4bfe845ae51925946a74ddcc802a6d`
- `pullPolicy`: `IfNotPresent`

## Security

- `securityContext` (container): `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Persistence

- `config`: enabled, `mountPath: /config`. No type or size set.

## Services

- `main`: port `5666` (http), targetPort `80`.
- `tcpport1`: port `5667` (tcp), targetPort `443`, enabled.

## Probes

- None defined.

## Env

- `env:` empty. No variables set.

## Gotchas

- Chart maps the app to container port 80 (HTTP) and 443 (HTTPS). Plan's 8080 choice is not from the chart.
- No probes defined, so healthcheck is unknown.
