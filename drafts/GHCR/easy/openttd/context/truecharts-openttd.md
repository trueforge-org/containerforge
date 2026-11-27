# TrueCharts openttd (chart 11.0.0, appVersion "latest")

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openttd/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Installs the OpenTTD release set in GAME_VERSION ("latest" = newest build, "testing" = newest testing build).
- Chart sources: ghcr.io/ich777/openttdserver, github.com/trueforge-org/truecharts (chart tree), openttd.org.
- Category GameServers, train stable, not deprecated. Keywords: openttd, GameServers.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/ich777/openttdserver |
| Tag | latest (digest pinned) |
| Pull policy | IfNotPresent |

## Ports
| Service | Service port | Target | Protocol |
| --- | --- | --- | --- |
| main | 9015 | 8080 | http |
| tcpgameport | 3979 | 3979 | TCP (enabled) |
| udpgameport | 3979 | 3979 | UDP (enabled) |

## Env vars (chart values)
| Var | Value |
| --- | --- |
| GAME_PARAMS | "" (empty) |
| GAME_VERSION | latest (pinned by digest) |
| GFX_PK_V | latest (pinned by digest, same as GAME_VERSION) |

## Persistence / paths
- serverfiles -> /serverdata/serverfiles (enabled).

## Probes / securityContext / args
- No probes, no args/command.
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- Chart pins GAME_VERSION via digest; the image's game-download logic is in upstream-openttd-dockerfile.md (scripts not fetched).
