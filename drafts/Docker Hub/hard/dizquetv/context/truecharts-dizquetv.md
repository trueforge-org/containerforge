# TrueCharts chart: dizquetv

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dizquetv
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dizquetv/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dizquetv/values.yaml
- Fetched 2026-11-26

## What it is
- Helm chart `dizquetv`, apiVersion v2, chart version 20.0.0, appVersion 1.7.0.
- Sources: truecharts chart dir, vexorian/dizquetv, hub.docker.com/r/vexorian/dizquetv.
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Annotations: trueforge.org/category "media", truecharts.org/train "stable", min helm 3.14, max helm 4.1, max kubernetes 1.35.0. No artifacthub images annotation.
- Chart files: CHANGELOG.md, README.md, values.schema.json, values.yaml, icon.webp, icon-small.webp, templates/, ci/.

## Container image (values.yaml)
- Main image: `docker.io/vexorian/dizquetv`, tag `1.7.0@sha256:693fa26624aa6cce8f84c0f883af78e62c5308c287eb506fdadb0870f42bddc3`, pullPolicy IfNotPresent.
- nvidiaImage variant: `docker.io/vexorian/dizquetv`, tag `1.7.0-nvidia@sha256:909c6f6f3c3ab2480a911612e6c25882f347d56bcec7b932d6c977ba1ebb5dd5`.

## Ports
- Service `main`, port `main`: port 10071 -> targetPort 8000.

## Volumes/paths and persistent data
- Persistence entry `config`: mountPath `/home/node/app/.dizquetv`, enabled true, no type specified.

## User/UID & permissions
- No securityContext or podSecurityContext defined in values.yaml (common library defaults apply).

## Env vars / resources
- None defined.

## Healthcheck/readiness endpoints
- Probes on container `main`: liveness, readiness and startup are all type http, path `/`.

## Gotchas
- Chart README: chart not maintained upstream; issues go to TrueCharts tracker.
- Chart uses the common library for most templating.
