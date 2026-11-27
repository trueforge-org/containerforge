# TrueCharts cstrike1-6 values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrike1-6/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/steamcmd`, pullPolicy IfNotPresent
- tag: `cstrike1.6@sha256:6f5d33c4719b6a82798c08abb2a714cfc7f8b4bbf8d540ee2c75d981b43a39fc` (branch tag `cstrike1.6`, pinned digest)

## Env vars (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `"90"` |
| GAME_MOD | `""` |
| GAME_NAME | `cstrike` |
| GAME_PARAMS | `+maxplayers 32 +map de_dust` |
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
- liveness, readiness, startup: type `tcp`, port 27015 (tcprcon targetPort). No explicit `enabled` key in values.

## Secrets
- secret `env-secrets` with key `PASSWRD: ""`
