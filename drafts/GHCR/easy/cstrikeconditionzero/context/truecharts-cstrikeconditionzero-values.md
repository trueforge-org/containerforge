# TrueCharts cstrikeconditionzero values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrikeconditionzero/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/steamcmd`, pullPolicy IfNotPresent
- tag: `cstrikeczero@sha256:18707ecd07b955187f556665ef65cf4847a300f9f972869b12882e2896fda44a` (branch tag `cstrikeczero`, pinned digest)

## Env vars (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `90 +app_set_config '90 mod dmc'` (not a clean app ID, see Gotchas) |
| GAME_MOD | `90 mod czero` |
| GAME_NAME | `czero` |
| GAME_PARAMS | `-secure +maxplayers 32 +map as_oilrig` |
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

## Gotchas
- `GAME_ID` holds extra steamcmd arguments. Upstream expands `${GAME_ID}` unquoted into `+app_update`, so it is not a usable app ID as set.
- `GAME_MOD` `90 mod czero` is the value passed to `+app_set_config` upstream.

## Secrets
- secret `env-secrets` with key `PASSWRD: ""`
