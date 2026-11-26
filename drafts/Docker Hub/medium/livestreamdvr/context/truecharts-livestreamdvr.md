# TrueCharts livestreamdvr (chart 11.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/livestreamdvr/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/livestreamdvr/Chart.yaml (2026-11-26)

## What it is
- Chart `version: 11.0.0`, `appVersion: master`, `type: application`, `kubeVersion: '>=1.33.0-0'`, category `MediaApp-Video`, train `stable`.
- Description: "An automatic twitch recorder."
- Library dep: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).

## Image
- `docker.io/mrbrax/twitchautomator`, tag `master@sha256:405ead3fef1c42ad8a38dd5dbd9c72ddeeed4e065739ceb90631fa9debc0bb4a`, `pullPolicy: IfNotPresent`.

## Args / env
- args: `--port {{ service.main.ports.main.port }}` (8146).
| Env (container `main`) | Value |
| --- | --- |
| TCD_ENABLE_FILES_API | `false` |
| TCD_EXPOSE_LOGS_TO_PUBLIC | `false` |
| TCD_MIGRATE_OLD_VOD_JSON | `false` |

## Ports
- service `main` / port `main`: 8146, protocol http. (Upstream image `EXPOSE 8080`, `TCD_SERVER_PORT=8080`; chart overrides via `--port`.)

## Volumes/paths (persistence, all enabled)
| Name | Mount |
| --- | --- |
| config | `/usr/local/share/twitchautomator/data/config` |
| cache | `/usr/local/share/twitchautomator/data/cache` |
| logs | `/usr/local/share/twitchautomator/data/logs` |
| storage | `/usr/local/share/twitchautomator/data/storage` |

## User/UID
- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Gotchas
- Chart pins `master`, not a release tag. Docker Hub `master` last updated 2025-01-21; `develop` 2025-05-05 (see dockerhub-twitchautomator.md).
- Chart `--port` arg makes the server listen on 8146, not the image's EXPOSE 8080.
