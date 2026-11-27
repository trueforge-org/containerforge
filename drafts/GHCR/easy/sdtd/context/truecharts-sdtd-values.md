# TrueCharts sdtd values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sdtd/values.yaml
- Fetched 2026-11-27

## What it is
TrueCharts Helm values for 7 Days to Die dedicated server, built on the ich777 SteamCMD image.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `7dtd@sha256:17fed39c47caed78a28f0e20131b16485d8167594564e5ccc235f022211eb329`
- pullPolicy: IfNotPresent

## Env vars (workload main container)
| Name | Value |
| --- | --- |
| BACKUP_FILES | `"false"` |
| BACKUP_INTERVAL | `"60"` |
| BACKUP_TO_KEEP | `"12"` |
| ENABLE_BEPINEX | `"false"` |
| GAME_ID | `"294420"` |
| GAME_PARAMS | `"-logfile 7DaysToDie_Data/output_log.txt $@"` |
| PASSWRD | secretKeyRef `env-secrets` / `PASSWRD` |
| SERVERCONFIG | `"serverconfig.xml"` |
| USERNAME | `""` |
| VALIDATE | `"false"` |

Secret `env-secrets` (PASSWRD default empty).

## Ports (service port / proto)
- main: 26900/tcp
- steammasterser: 26900/udp
- raknet: 26902/udp
- registeringats: 27015/udp
- steamcommunica: 26901/udp
- unet: 26903/udp
- webbasecontrol: 8080/tcp
- webpanel: 8082/tcp

## Volumes/paths
- serverfiles → `/serverdata/serverfiles`
- steamcmd → `/serverdata/steamcmd`

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false (chart runs as root with writable rootfs).

## Healthcheck
- Only startup probe: failureThreshold 360. No liveness/readiness defined.

## Gotchas
- Container command/args not set in values; relies on image entrypoint.
- GAME_PARAMS includes `$@` literal.
