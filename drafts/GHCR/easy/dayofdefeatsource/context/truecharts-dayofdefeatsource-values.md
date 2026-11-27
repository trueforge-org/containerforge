# TrueCharts dayofdefeatsource values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayofdefeatsource/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/steamcmd`, pullPolicy IfNotPresent
- tag: `dods@sha256:5e0ed6189a9f94d0cd6f69eff78b6162d76f97b127046085de0061931348a7a9` (branch tag `dods`, pinned digest)

## Env vars (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `"232290"` |
| GAME_NAME | `dod` |
| GAME_PARAMS | `-secure +maxplayers 24 +map dod_kalt` |
| GAME_PORT | `"27015"` |
| PASSWRD | secretKeyRef `env-secrets` / `PASSWRD` |
| USERNAME | `""` |
| VALIDATE | `"false"` |

## Ports (service)
| Name | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 27015 | udp | 27015 |
| tcprcon (enabled) | 27015 | tcp | 27015 |

## Volumes/paths (persistence)
- `serverfiles` enabled, `/serverdata/serverfiles`
- `steamcmd` enabled, `/serverdata/steamcmd`

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Healthcheck / probes
- liveness, readiness, startup: type `tcp`, port 27015 (tcprcon targetPort)

## Secrets
- secret `env-secrets` with key `PASSWRD: ""`
