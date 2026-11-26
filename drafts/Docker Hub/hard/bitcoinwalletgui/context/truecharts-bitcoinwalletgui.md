# TrueCharts chart: bitcoinwalletgui

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitcoinwalletgui/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitcoinwalletgui) · fetched 2026-11-26

## Container image
- repository `docker.io/ulisses1478/bitcoinwallet-gui`
- tag `latest@sha256:b118585cecd11e1feaa6242c1bfd1e31bc70abd45f590f2556fb506ad209faa7`
- pullPolicy `IfNotPresent`

## Ports
- main: port `6901`, protocol http, targetPort 6901 (noVNC).
- vncport (enabled): port `5905`, tcp, targetPort `5901` (VNC).

## Env vars
- `VNC_PW` from secret `env-secrets` key `VNC_PW` (secret value in chart: `vncpassword`).
- `VNC_RESOLUTION` `1280x1024`; `VNC_VIEW_ONLY` `false`.

## User/UID & permissions
`runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`. `privileged` not set.

## Volumes/paths
`bitcoinblockchainpath` at `/headless/.bitcoin/`.

## Healthcheck/readiness
No probes defined.

## Gotchas
- Chart exposes the VNC server (5901) on a second port (5905 service) with a password from a secret.
- Chart's default secret password is a placeholder; must be changed.

## Contradictions with plan.md
- plan.md Ports `6080`/`5900`: the chart uses 6901 and 5901 targets. Corrected in plan.md.
