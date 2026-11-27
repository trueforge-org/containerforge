# TrueCharts chroma (stable chart v9.0.0, appVersion 1.5.9)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chroma/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chroma/Chart.yaml (fetched 2026-11-27)

## What it is
- "the AI-native open-source embedding database."
- Chart sources: ghcr.io/chroma-core/chroma, github repo.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- repository: `ghcr.io/chroma-core/chroma`
- tag: `1.5.9@sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6`
- pullPolicy: IfNotPresent

## Env vars (chart)
| Name | Value |
| --- | --- |
| IS_PERSISTENT | true |

## Ports
- main: service port 10690 -> targetPort 8000, protocol http.

## Probes (chart)
- liveness, readiness, startup: path `/api/v2/heartbeat` (enabled by default in chart).

## Volumes/paths
- persistence `config` at `/chroma/chroma` (enabled).

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Gotchas
- Chart service port 10690 differs from upstream EXPOSE 8000 (container port).
- Chart persists to `/chroma/chroma`; upstream config.py default persist_directory is `./chroma` (relative to WORKDIR /chroma).
