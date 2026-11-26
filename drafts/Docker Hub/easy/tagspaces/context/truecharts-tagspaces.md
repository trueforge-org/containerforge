# TrueCharts tagspaces chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tagspaces/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `tagspaces`, built on the fardjad Lite web image.

## Image used by chart
`docker.io/fardjad/tagspaces-lite-web` tag `6.0.2@sha256:43be8dd45512775b546f25c8b2ddeac29d2fa7680ca78387a77b490993efcbcc`, pullPolicy IfNotPresent.

## Service
main: http, port 80 (targetPort 8080).

## Env vars set by chart
`KEY` from secret `tagspaces-secret` (key `KEY`). The chart's values define `tagspaces.key` as a placeholder ("Must be changed. Secret key, 32 characters recommended.").

## Persistence
`nginx`: emptyDir at `/var/cache/nginx`.

## Security
securityContext.container: readOnlyRootFilesystem false (no runAs settings).

## Probes
None.

## Contradictions with plan.md
- plan.md section 1 says the lite web build has no server env vars. The chart sets a `KEY` env from a secret. Whether the image reads `KEY` is not confirmed by any fetched source. Unverified; left as is.
- plan.md section 9 mentions the chart's emptyDir at `/var/cache/nginx` (matches).
- Chart runs without runAs; plan.md's UID 568 matches the common default per the draft.
