# TrueCharts stationeers values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/stationeers/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `stationeers@sha256:26d2c8d6d1930fc3e12f7536705e9d55f3b19e11c8e18f79f78a17268f814e82`
- pullPolicy: IfNotPresent

## Ports
- gameport service: `27500/udp` → `27500`
- main service: `27015/udp` → `27015`

## Env vars
| Name | Value |
| --- | --- |
| GAME_ID | `"600760"` (Stationeers Steam app id) |
| GAME_PARAMS | `"AutoSave true SaveInterval 300"` |
| VALIDATE | `"false"` |
| USERNAME | `""` |
| PASSWRD | secretKeyRef `env-secrets` / `PASSWRD` (empty) |

- GAME_NAME not set in values.

## Volumes/paths
- serverfiles → `/serverdata/serverfiles`
- steamcmd → `/serverdata/steamcmd`

## User/UID, probes, securityContext
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, fsGroup not set
- liveness, readiness, startup probes all disabled.

## Gotchas
- Chart's GAME_PARAMS differs from the ich777 Stationeers default (`-difficulty easy -loadlatest Mars Mars`) recorded in plan.md.
