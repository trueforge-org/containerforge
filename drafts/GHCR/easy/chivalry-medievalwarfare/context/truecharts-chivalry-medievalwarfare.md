# TrueCharts chivalry-medievalwarfare (stable chart v11.0.0, appVersion "chialrymw" typo upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chivalry-medievalwarfare/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chivalry-medievalwarfare/Chart.yaml (fetched 2026-11-27)

## What it is
- "This Chart will download and install SteamCMD. It will also install Chivalry: Medieval Warfare and run it."
- Chart sources: ghcr.io/ich777/steamcmd, truecharts chart path, steampowered.com.
- Dependency: `common` 32.8.5.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `chivalrymw@sha256:d8b91714e90aa923171ada13b54a4a5ce38ece9aa1669e976f4f0eeae712bc5e`
- pullPolicy: IfNotPresent

## Env vars (chart)
| Name | Chart value |
| --- | --- |
| GAME_ID | "220070" (Steam app ID) |
| GAME_PARAMS | `?port=7000?queryport=7010` |
| GAME_PARAMS_EXTRA | `-seekfreeloadingserver` |
| MAP | `aocffa-moor_p` |
| ADMIN_PWD | secretKeyRef env-secrets/ADMIN_PWD (default "adminDocker" in secret) |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (empty) |
| USERNAME | "" (anonymous login) |
| VALIDATE | "true" |

## Ports
| Service | Port | Proto |
| --- | --- | --- |
| main | 7000 | udp |
| gamequeryport | 7010 | udp |
| steamqueryport | 27015 | udp |

## Volumes/paths (persistence)
- `/serverdata/serverfiles`, `/serverdata/steamcmd`

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck
- liveness, readiness, startup all disabled.

## Gotchas
- All service ports are UDP.
- Chart's secret default ADMIN_PWD is "adminDocker" (non-empty) in values.
