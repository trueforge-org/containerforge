# TrueCharts chart: fileflows

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fileflows (chart values via raw `values.yaml`, fetched 2026-11-26)

## Image

- `repository`: `docker.io/revenz/fileflows`
- `tag`: `26.11@sha256:e3b9435e5241f6bea790dce0d74d17c218139870373a3c87d56992e9bbd442bc`
- `pullPolicy`: `IfNotPresent`

## Security

- `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, `privileged: true`, `allowPrivilegeEscalation: true`.

## Persistence

- `data` -> `/app/Data`, `logs` -> `/app/Logs`, `temp` -> `/temp`, `media` -> `/media`. All enabled, no `type` given.

## Ports

- service `main` port `10242` -> targetPort `5000`.

## Env

- `env: {}` (none). No devices or hardware keys.

## Probes

- liveness, readiness and startup: HTTP `/`.

## Gotchas

- The chart's paths (`/app/Data`, `/app/Logs`, `/temp`, `/media`) are the same as the plan's draft expectations; plan remaps data to `/config/Data`.
- `privileged: true` is the chart's choice; upstream docs do not require privilege (hardware access is via devices or runtimes per docs).
