# TrueCharts cs2 values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cs2/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/steamcmd`, pullPolicy IfNotPresent
- tag: `cs2@sha256:6c8e46d4300d27c33548a1a151da87b02d8afba37bd8b94970b9d14fcd4d2288` (branch tag `cs2`, pinned digest)

## Env vars (workload.main.podSpec.containers.main.env, templated from values)
| Name | Value |
| --- | --- |
| STEAMCMD_DIR | `{{ persistence.steamcmd.mountPath }}` = `/serverdata/steamcmd` |
| SERVER_DIR | `{{ persistence.serverfiles.mountPath }}` = `/serverdata/serverfiles` |
| GAME_PORT | `{{ service.main.ports.main.port }}` = 27015 |
| GAME_ID | `{{ cs2.game.id }}` = 730 |
| USERNAME | `{{ cs2.game.user }}` = "" |
| PASSWRD | secretKeyRef `env-secrets` / `PASSWRD` |
| GAME_PARAMS | join of `cs2.game.params` (see below) |
| VALIDATE | `{{ cs2.game.validate }}` = false |

`cs2.game.params` defaults: `-dedicated`, `-dev`, `+map de_inferno`, `+game_type 0`, `+game_mode 1`, `-usercon`.

## Ports (service)
| Name | Port | Proto | Note |
| --- | --- | --- | --- |
| main | 27015 | udp | game port (GAME_PORT) |
| rcon (enabled) | 27020 | tcp | rcon |

## Volumes/paths (persistence)
- `steamcmd` enabled, `/serverdata/steamcmd`
- `serverfiles` enabled, `/serverdata/serverfiles`

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Healthcheck / probes
- liveness, readiness, startup: all `enabled: false`

## Gotchas
- Secret template `PASSWRD: '{{ .Values.cs2.game.password }}'` references a key `password` that is not in values (values has `pass: ""`). Chart-side issue.
