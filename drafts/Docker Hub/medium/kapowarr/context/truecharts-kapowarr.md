# TrueCharts kapowarr (chart 6.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kapowarr/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kapowarr/Chart.yaml (2026-11-26)

## What it is
- Chart `version: 6.0.0`, `appVersion: 1.0.0`, `kubeVersion: '>=1.33.0-0'`, category `media`, train `stable`.
- Description: comic book library manager, "fitting in the *arr suite".
- Library dep: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).

## Image
- `docker.io/mrcas/kapowarr`, tag `v1.0.0-beta-4@sha256:951c583aa0a5a80091bd393fc1ce9770b18fe7ce3ed146835921bfc9afcdc631`.
- `pullPolicy: IfNotPresent`.

## Env vars
- None set in chart values (no `env:` block).

## Ports
- service `main` / port `main`: 5656, `protocol: http`, `targetPort: 5656`.

## Probes
- liveness, readiness, startup: HTTP GET `/` (no port override; uses service port).

## Volumes/paths
| Persistence | Enabled | Mount |
| --- | --- | --- |
| downloads | true | `/app/temp_downloads` |
| media | true | `/comics-1` |
| db | true | `/app/db` |
- No `/config` mount.

## User/UID
- `securityContext.container.runAsUser: 0`, `runAsGroup: 0` (root).

## Gotchas
- Chart pins `v1.0.0-beta-4` (2024-01-03). Docker Hub latest is v1.3.2 (2026-09-14). Chart `appVersion` 1.0.0.
- Chart media mount is `/comics-1`; upstream v1.3.2 docs map root folder to `/comics` (see casvt-docs-docker.md). Chart and upstream naming differ.
