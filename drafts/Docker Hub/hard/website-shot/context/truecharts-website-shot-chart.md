# TrueCharts website-shot chart (reference only)

## Source URL(s) + date
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/website-shot (tree page fetched 2026-11-26; listing parsed, not full HTML)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/website-shot/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/website-shot/values.yaml

## What it is
- Helm chart `website-shot`, chart version 16.0.0, appVersion `latest`, train `stable`, category media.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`.

## Image (values.yaml)
- repository `docker.io/flowko1/website-shot`
- tag `latest@sha256:816d2e0d66a83e0befbd63b3bd174cb239e3d2bd15d469cec72d1bcb6eca26cd`
- pullPolicy IfNotPresent

## Security context (values.yaml)
- readOnlyRootFilesystem: false
- runAsUser 1000, runAsGroup 1000

## Ports
- service main port 10221 -> targetPort 3000

## Volumes/paths
- persistence `screenshots`: enabled, mountPath `/usr/src/website-shot/screenshots`

## Sources listed in Chart.yaml
- https://github.com/Flowko/website-shot
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/website-shot
- https://hub.docker.com/r/flowko1/website-shot
