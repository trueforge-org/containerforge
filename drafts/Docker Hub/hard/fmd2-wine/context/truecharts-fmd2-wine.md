# TrueCharts chart: fmd2-wine

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fmd2-wine (values via raw `master/charts/stable/fmd2-wine/values.yaml`)

## Image

- `repository`: `docker.io/banhcanh/docker-fmd2`
- `tag`: `latest@sha256:153ccc161e7ed9f2b44f6ec7176ed4e5e53fc0962465d3556176b6489eae20eb`
- `pullPolicy`: `IfNotPresent`

## Security

- `securityContext` (container): `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Persistence (type and size not set for any entry)

| Name | mountPath |
| --- | --- |
| lua | `/app/FMD2/lua` |
| user | `/app/FMD2/userdata` |
| config | `/config/.wine` |
| data | `/app/FMD2/data` |
| downloads | `/downloads` |

## Services

- `main` port `6080` (tcp), targetPort `6080`.

## Probes and env

- No probes defined. No env values defined.

## Gotchas

- CONFLICT: chart's service port is `6080`, but the upstream image (`github-banh-canh-docker-fmd2.md`) exposes `3000` (KasmVNC web UI). Plan's `3000` / `3001` are consistent with upstream; the chart value may be an outdated or different port. Not resolved from sources.
- Persistence includes `/config/.wine` (Wine prefix), matching the plan's `/config/.wine` choice.
