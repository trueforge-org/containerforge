# TrueCharts rust chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rust/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rust/Chart.yaml
- Fetched 2026-11-27

## What it is
- "This Chart will download and install SteamCMD. It will also install RUST and run it." Chart 11.0.0, appVersion `rust` (non-numeric), GameServers
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/ich777/steamcmd, Steam homepage

## Image (values.yaml)
- repository: `ghcr.io/ich777/steamcmd` (GHCR, no Docker Hub source)
- tag: `rust@sha256:246d4d8287bc42d5c5bc46806bf772e3bc7864bfa7df0a24d1c5f26be468c8c9`
- pullPolicy: IfNotPresent

## Env (workload.main container)
| Name | Value |
| --- | --- |
| GAME_ID | "258550" |
| GAME_PARAMS | +server.maxplayers 10 |
| GAME_PORT | "28015" |
| OXIDE_MOD | "" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |
| SERVER_DISCRIPTION | Simple Unraid Rust Docker Server (key spelled this way in chart) |
| SERVER_NAME | RustDockerServer |
| USERNAME | "" |
| VALIDATE | "false" |

- GAME_NAME is NOT set by the chart (image default is `template`, see ich777 file)

## Secrets
- secret `env-secrets`: PASSWRD ''

## Ports (service)
| Service | Port | Proto |
| --- | --- | --- |
| main | 28015 | udp |

## Persistence
| Name | Mount |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Probes / security
- probes liveness/readiness/startup disabled
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Gotchas
- Chart does not set GAME_NAME. The ich777 start path uses `srcds_run -game ${GAME_NAME} ...` (see `ich777-docker-steamcmd-server.md`), so the Rust server launch depends on how the ich777 rust tag handles that. Not verified; the rust branch Dockerfile/script was not in the URL list.
