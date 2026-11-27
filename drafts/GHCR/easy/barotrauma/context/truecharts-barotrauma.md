# TrueCharts barotrauma (stable chart v11.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/barotrauma/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/barotrauma/Chart.yaml (fetched 2026-11-27)

## What it is
- "This Chart will download and install SteamCMD. It will also install Barotrauma and run it."
- `appVersion: barotrauma` (no numeric version in chart).
- Chart sources: ghcr.io/ich777/steamcmd, truecharts chart path, steampowered.com.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `barotrauma@sha256:50f088288938f04b389c2e669d3c7a8dcae3fcf39976772d746150c37e0736d4`
- pullPolicy: IfNotPresent

## Env vars (chart)
| Name | Chart default | Notes |
| --- | --- | --- |
| GAME_ID | "1026340" | Steam app ID (Barotrauma) |
| GAME_PARAMS | "" | extra server params |
| PASSWRD | secretKeyRef env-secrets/PASSWRD | server password (secret) |
| USERNAME | "" | Steam login |
| VALIDATE | "false" | SteamCMD validate flag |

## Ports
| Service | Port | Proto |
| --- | --- | --- |
| main | 27015 | udp |
| steamqueryport | 27016 | udp (enabled) |

## Volumes/paths (persistence)
- `/serverdata/serverfiles`
- `/serverdata/steamcmd`

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck
- liveness, readiness, startup probes all disabled.

## Gotchas
- Chart uses the ich777 steamcmd image, not a ContainerForge base.
- Chart lists no TCP ports; both service ports are UDP.
