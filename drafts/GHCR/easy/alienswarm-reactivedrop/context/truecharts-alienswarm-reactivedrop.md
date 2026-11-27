# TrueCharts chart: alienswarm-reactivedrop

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm-reactivedrop/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm-reactivedrop/values.yaml (2026-11-27)

## What it is
- Chart `alienswarm-reactivedrop` v11.0.0, category GameServers (from sibling chart pattern), train stable.
- Description: downloads and installs SteamCMD, then installs Alien Swarm: Reactive Drop and runs it.
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- `ghcr.io/ich777/steamcmd`
- tag `alienswarmreactivedrop@sha256:bb03282a0b85fee8340505ca1f49b7351f79812f123e3753fd19476896c8a28d`
- pullPolicy IfNotPresent
- Chart `appVersion: alienswarmreactiedrop` (typo: "reactiedrop"), differs from image tag `alienswarmreactivedrop`.

## Env vars
| Name | Value |
| --- | --- |
| GAME_ID | "563560" (Steam app ID) |
| GAME_NAME | reactivedrop |
| GAME_PARAMS | `+map lobby -maxplayers 4 +exec server.cfg` |
| GAME_PORT | "27015" |
| PASSWRD | secretKeyRef `env-secrets` key `PASSWRD` (default "") |
| USERNAME | "" (anonymous) |
| VALIDATE | "false" |

## Ports
| Service | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 27015 | udp | 27015 |
| tcprconport (enabled) | 27015 | tcp | 27015 |

- Probes (liveness, readiness, startup) are `type: tcp` on tcprconport 27015.

## Volumes / paths
- `/serverdata/serverfiles` (persistence `serverfiles`)
- `/serverdata/steamcmd` (persistence `steamcmd`)

## Security context
- `readOnlyRootFilesystem: false`, `runAsGroup: 0`, `runAsUser: 0`.

## Gotchas
- Chart `appVersion` typo does not affect the image tag, which is the value used.
- Same env and persistence layout as the alienswarm chart (sibling), differing in app ID 563560 and GAME_NAME.
