# TrueCharts pavlovvr chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pavlovvr/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pavlovvr/Chart.yaml
- Fetched 2026-11-27

## What it is
- Chart description: "This Chart will download and install SteamCMD. It will also install Pavlov VR and run it."
- Chart version 12.0.0, appVersion `palor`, category GameServers, train stable
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`
- Sources listed: ghcr.io/ich777/steamcmd, Steam homepage

## Image (values.yaml)
- repository: `ghcr.io/ich777/steamcmd` (GHCR, not Docker Hub)
- tag: `pavlovvr@sha256:6131e0be611e55f4df02feb7e249d9ffa1724ff4911a8f38a640e39cf9a9a2f7`
- pullPolicy: IfNotPresent

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | "622970" |
| GAME_PARAMS | "" |
| VALIDATE | "false" |

## Secrets
| Name | Value |
| --- | --- |
| secretEmv.PASSWRD | "" |
| secretEmv.USERNAME | "" |

## Ports (service)
| Service | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 7777 | tcp | 7777 |
| mainudp | 7777 | udp | 7777 |
| udp2 | 8177 | udp | 8177 |
| udp3 | 7977 | udp | 7977 |

## Volumes (persistence)
| Name | Mount path |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Security
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Not in values.yaml
- Probes, healthcheck, config files: none set in the chart values
