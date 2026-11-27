# TrueCharts chart: golinks

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/golinks/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/golinks/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `golinks`, `appVersion: 154c581` (TrueCharts chart build tag, not an upstream release). Train `stable`, category `media`.
- Description: web app for smart bookmarks/aliases via browser default search engine.
- Chart common dependency 32.8.5 (`oci://oci.trueforge.org/truecharts`).

## Image
- `repository: ghcr.io/nicholaswilde/golinks`
- `tag: version-154c581@sha256:8e67b26324c5dc433210df8f2fb64317db3cbbe7db0b9e10c6e5bc3f3f7860e4`
- Note: image is in nicholaswilde's GHCR namespace. The packaging repo `github.com/nicholaswilde/docker-golinks` was listed but not fetched.

## Env vars (chart)
- `env: {}` (none set by chart).

## Ports
- Service `main`: port 10073 -> targetPort 8000.

## Volumes/paths
- `persistence.data`: enabled, `mountPath: /data`.
- `persistence.varrun`: enabled (no mountPath set in values).

## User/UID
- Chart: `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`.

## Config files
- None in chart.

## Healthcheck
- None set in chart.

## Gotchas
- Chart mounts `/data` but upstream start.sh defaults `DBPATH=/search.db` (root of the filesystem). Chart does not set `DBPATH`, so the DB lands on `/search.db` unless the image overrides it.
- Target port 8000 is the upstream bind (`BIND=0.0.0.0:8000`).
