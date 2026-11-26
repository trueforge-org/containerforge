# TrueCharts slack-invite chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slack-invite/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `slack-invite`. Single `main` workload, port 7879.

## Image used by chart
`docker.io/ninthwalker/slack-invite` tag `latest@sha256:25a38b1ee28baf78046162bcaf90962eee3ad79b60666f5451e5f30e5a0c0dda`, pullPolicy IfNotPresent.

## Env vars set by chart
- `COMMUNITY_NAME`: `myslackteam` (placeholder)
- `SLACK_URL`: `myslackteam.slack.com` (placeholder)
- `SLACK_TOKEN`: from secret `env-secrets` (placeholder value in the chart's secret)
- No INVITE_TOKEN, LOCALE or PORT set (defaults used)

## Service
main port 7879, protocol tcp.

## Persistence
`persistence: {}` (none).

## Security
securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
None in values.yaml.

## Contradictions with plan.md
- Matches plan.md: runAsUser 0, readOnlyRootFilesystem false, no persistence, port 7879.
