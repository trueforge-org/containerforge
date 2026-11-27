# TrueCharts conanexiles values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/conanexiles/values.yaml (fetched 2026-11-27)

## What it is
Chart values for Conan Exiles dedicated server, using the ich777 SteamCMD wrapper image.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `conanexiles@sha256:fed82b7c95bada0cf9d3a116b0f529fef972f425c9b1d4dd4b4bf27168763c7a` (branch-style tag `conanexiles`, pinned digest)
- pullPolicy: IfNotPresent

## Env vars (table, workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `"443030"` |
| GAME_PARAMS | `""` |
| USERNAME | `""` |
| PASSWRD | secretKeyRef `env-secrets` / `PASSWRD` |
| VALIDATE | `"false"` |
| WS_CONTENT | `""` |

## Ports (service)
| Name | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 7777 | udp | 7777 |
| gameport1 (enabled) | 7778 | udp | 7778 |
| steamport (enabled) | 27015 | udp | 27015 |

## Volumes/paths (persistence)
- `serverfiles` enabled, mountPath `/serverdata/serverfiles`
- `steamcmd` enabled, mountPath `/serverdata/steamcmd`

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Healthcheck / probes
- liveness, readiness, startup: all `enabled: false`

## Secrets
- secret `env-secrets` with key `PASSWRD: ""`
