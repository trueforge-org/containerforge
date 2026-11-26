# TrueCharts zilean chart (reference only)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zilean/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zilean/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zilean not parsed.

## What it is
- Helm chart `zilean`, chart version 7.0.0, appVersion 3.5.0. Description: "Zilean self-hosted".
- Depends on `common` 32.8.5 and `postgresql` (enabled, user `postgres`, db `zilean`).

## Image (values.yaml)
- repository `docker.io/ipromknight/zilean`
- tag `v3.5.0@sha256:1b828ac0604235de7adb7757d11c88c1b3bb1a6319071b0c9d99325bc0f9d477`

## Ports
- service main 8181 -> 8181

## Probes
- liveness, readiness, startup: HTTP path `/healthchecks/ping`

## Env / secrets
- `Zilean__Database__ConnectionString` from secret `env-secrets`, built as `Host=<plainhost>;Port=5432;Database=zilean;Username=postgres;Password=<pw>`.

## Persistence
- `data` -> `/app/data`

## Gotchas
- Chart probes use `/healthchecks/ping` on port 8181. Not verified against upstream code in this pass.
- Chart connection string uses user `postgres`; plan.md's default uses user `zilean`.
