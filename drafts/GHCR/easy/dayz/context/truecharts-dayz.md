# TrueCharts chart: dayz

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayz/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayz/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `dayz`, chart version 11.0.0, appVersion `dayz`, category GameServers, train stable.
- Description: installs SteamCMD and then installs and runs DayZ.
- Chart sources: `ghcr.io/ich777/steamcmd`, the TrueCharts chart dir, https://www.bohemia.net/games/dayz.
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` (GHCR, not Docker Hub) |
| tag | `dayz@sha256:e29a926edc29addf4067c3a1c785df265b84c6533e0877650c5553b138037816` |
| pullPolicy | IfNotPresent |

## Runtime env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | "1042420" |
| GAME_PARAMS | "" |
| GAME_PORT | "2302" |
| PASSWRD | secretKeyRef `env-secrets`/`PASSWRD` (empty default) |
| USERNAME | "" |
| VALIDATE | "false" |

## Ports
| Name | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 2302 | udp | 2302 |
| steamqueryport | 27016 | udp | 27016 |

## Volumes
| Persistence | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Security context
- readOnlyRootFilesystem: false
- runAsUser: 0, runAsGroup: 0 (root)

## Probes
- liveness, readiness, startup all `enabled: false`.

## Gotchas
- Chart image is GHCR, so no Docker Hub page exists for this image.
- `PASSWRD` is a Steam login password (SteamCMD auth), not a DayZ server password.
- Chart has no 2303/2304 ports; 27016/udp is the steam query port.
