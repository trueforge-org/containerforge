# TrueCharts chart: acestream

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/acestream/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/acestream) · fetched 2026-11-26

## What it is
TrueCharts Helm chart values for `acestream`.

## Config files and formats
Helm `values.yaml` (common library schema).

## Container image
- repository `docker.io/vstavrinov/acestream-service`
- tag `2.1.1.1@sha256:36683f89bd1e8ac7a6e4faed0af1342018dcb4d551d695eb957d201473ed7839`
- pullPolicy `IfNotPresent`

## Ports
Service `main` port `8008`, tcp.

## Env vars
| Name | Value |
| --- | --- |
| `ENTRY` | `{{ .Values.service.main.ports.main.port }}` (8008) |
| `PORT` | `{{ .Values.service.main.ports.main.port }}` (8008) |
| `SCHEME` | `http` |

## User/UID & permissions
`runAsUser: 1000`, `runAsGroup: 1000`, `readOnlyRootFilesystem: false`. `privileged` not set. Chart comment: image uses its own `ace` user and keeps cache and nginx config in `/dev/shm`.

## Volumes/paths
No persistence entries defined.

## Healthcheck/readiness endpoints
No probes defined.

## Gotchas
- Chart sets `ENTRY` and `PORT` both to 8008, and `SCHEME=http`. Plan.md section 9 says the chart "sets 8008"; consistent.
- Chart image tag includes a digest pin that plan.md section 1 does not mention (plan.md lists only the tag `2.1.1.1`).

## Contradictions with plan.md
- None on port or user. plan.md section 9 says the chart ran as uid 1000 with `readOnlyRootFilesystem: false`: confirmed.
