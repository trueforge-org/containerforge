# TrueCharts csgo values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/csgo/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/steamcmd`, pullPolicy IfNotPresent
- tag: `latest@sha256:5763fe62a7f9a5f81a46729aa1182f8a18e97877ac962772abbf4c49cfc18ec8` (rolling tag, pinned digest)

## Env vars (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `"740"` |
| GAME_NAME | `csgo` |
| GAME_PARAMS | `+game_type 0 -usercon +game_mode 0 +mapgroup mg_active +map de_dust2` |
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
- liveness, readiness, startup: all enabled, type `tcp`, port 27015 (tcprcon targetPort)

## Secrets
- secret `env-secrets` with key `PASSWRD: ""`
