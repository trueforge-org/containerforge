# TrueCharts apache-musicindex (chart 17.0.0)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/apache-musicindex/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart `apache-musicindex`, version 17.0.0, appVersion 1.4.1, category media, train stable.
- Description: index and stream music using apache-musicindex and m3u playlists.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.
- Chart `sources`: https://ghcr.io/k8s-at-home/apache-musicindex

## Image
- repository: `ghcr.io/k8s-at-home/apache-musicindex`
- tag: `v1.4.1-2@sha256:c9bd82dc5fdaaad16a9a07c61672e29886d9399c7eee6e57f1d758124783c34a`
- pullPolicy: IfNotPresent

## Security context (chart defaults)
- readOnlyRootFilesystem: false
- runAsNonRoot: false, runAsUser: 0, runAsGroup: 0

## Ports
| Name | Protocol | Port | targetPort |
| --- | --- | --- | --- |
| main | http | 10006 | 80 |

## Env / persistence / probes
- No env, persistence or probe overrides in values.yaml (only image, securityContext, service).

## Gotchas
- Container listens on port 80 inside; chart exposes 10006 on the service. Upstream image tag `v1.4.1-2` is a k8s-at-home image tag, not a Docker Hub image.
