# TrueCharts daysofwar values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/daysofwar/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/steamcmd`, pullPolicy IfNotPresent
- tag: `daysofwar@sha256:59072499aaf86ab98d031fda6b5ebd5cc28079371b9835e3d48af5fab6ac907f` (branch tag `daysofwar`, pinned digest)

## Env vars (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `"541790"` |
| GAME_PARAMS | `dow_cathedral` |
| GAME_PORT | `"7777"` |
| QUERY_PORT | `"27015"` |
| PASSWRD | secretKeyRef `env-secrets` / `PASSWRD` |
| USERNAME | `""` |
| VALIDATE | `"false"` |

No GAME_NAME is set in values.

## Ports (service)
| Name | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 7777 | udp | 7777 |
| steamport (enabled) | 27015 | udp | 27015 |

## Volumes/paths (persistence)
- `serverfiles` enabled, `/serverdata/serverfiles`
- `steamcmd` enabled, `/serverdata/steamcmd`

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Healthcheck / probes
- liveness, readiness, startup: all `enabled: false`

## Secrets
- secret `env-secrets` with key `PASSWRD: ""`
