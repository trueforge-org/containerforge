# TrueCharts: nntp2nntp chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/nntp2nntp (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nntp2nntp/values.yaml)
**Fetched:** 2026-11-26

## Image
- `ghcr.io/linuxserver/nntp2nntp:0.3.20230704`, digest `06c3e47ba3f35c18c1fbd8ac79572149db5bb95e377bdd2835e6f6e66bab4a64`, IfNotPresent. The LinuxServer image is the one the draft pins (plan.md's tag is `0.3`).

## Service
- `main`, port `main`: port 1563, targetPort 1563.

## Env
None defined.

## Persistence
- `config`: enabled, mounted at `/config`. No size, readOnly.
- `varrun`: enabled, no mount path, size or readOnly given.

## Security context
- `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`. `readOnlyRootFilesystem` not specified.

## Probes
- Liveness, readiness and startup all type `tcp`.

## Other
- Schema reference `./values.schema.json`.
- The chart's `varrun` volume is the linuxserver image's pid location; our config points the pidfile at `/config/logs`, so `varrun` is not needed.
