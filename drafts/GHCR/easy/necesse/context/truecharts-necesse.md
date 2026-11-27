# TrueCharts necesse (chart 11.0.0, appVersion "necesse")

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/necesse/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "This Chart will download and install SteamCMD. It will also install Necesse and run it."
- Category GameServers, train stable, not deprecated. Keywords: necesse, GameServers.
- Chart sources: ghcr.io/ich777/steamcmd, github.com/trueforge-org/truecharts (necesse tree), steampowered.com.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/ich777/steamcmd |
| Tag | `necesse@sha256:05f53d15007698715b2801ab13d32211a1bd79be023def280b37459e6cd894b3` (tag is the Necesse variant, digest pinned) |
| Pull policy | IfNotPresent |

## Ports
| Service | Port | Protocol | Target | Enabled |
| --- | --- | --- | --- | --- |
| main | 9023 | http | 8080 | not specified |
| udpgameport | 14159 | udp | 14159 | true |

## Env vars (chart values)
| Var | Value |
| --- | --- |
| GAME_ID | "1169370" (Steam app id) |
| GAME_PARAMS | "" (empty; launch params passed here) |
| WORLD_NAME | World |

## Persistence / paths
| Name | Enabled | Mount |
| --- | --- | --- |
| serverfiles | true | /serverdata/serverfiles |
| steamcmd | true | /serverdata/steamcmd |

## Security context / probes / args
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- No probes defined. No command/args set.

## Gotchas
- Game launch parameters go through GAME_PARAMS (empty by default). Valid Necesse server flags are in necesse-sites.md.
- Chart's main HTTP port 9023 -> 8080 target has no matching documented server listener in fetched sources; only UDP 14159 is documented as the game port.
