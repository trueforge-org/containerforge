# TrueCharts chart: v-rising

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/v-rising/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/ich777/steamcmd` tag `vrising` (SteamCMD base that installs/runs V Rising dedicated server, Steam AppID 1829350).
- Chart `version: 11.0.0`, `appVersion: rising`, category GameServers, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/ich777/steamcmd`, `tag: vrising@sha256:e04e6726...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target | Protocol |
| --- | --- | --- | --- |
| main | 9876 | 9876 | udp |
| query (enabled) | 9877 | 9877 | udp |

## Env vars (chart)
| Var | Value |
| --- | --- |
| ENABLE_BEPINEX | "" |
| GAME_ID | "1829350" |
| GAME_PARAMS | "" |
| PASSWRD | secret `env-secrets` key PASSWRD (default "") |
| SERVER_NAME | V Rising Docker |
| USERNAME | "" |
| VALIDATE | "false" |
| WORLD_NAME | world1 |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| serverfiles | /serverdata/serverfiles | enabled |
| steamcmd | /serverdata/steamcmd | enabled |

## Probes
- liveness, readiness, startup: all `enabled: false`.

## User/UID
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Gotchas
- Chart sets `SERVER_NAME`, `WORLD_NAME`, `PASSWRD`, `GAME_ID`; these are not verified against the image start script (not fetched). Upstream native overrides are `VR_NAME`, `VR_GAME_PORT`, `VR_QUERY_PORT`, `VR_SAVE_NAME`, `VR_RCON_PORT`, `VR_RCON_PASSWORD`; chart does not set any `VR_*` var.
- Chart port 9876/9877 vs upstream examples 27015/27016 (examples only; no default given).
- Chart runs as root with writable rootfs.
