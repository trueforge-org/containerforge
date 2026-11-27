# TrueCharts anything-llm (chart 7.0.2)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anything-llm/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart: `anything-llm`, version 7.0.2, appVersion `latest`, category AI, train stable.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Chart `sources`: ghcr.io/mintplex-labs/anything-llm, github Mintplex-Labs/anything-llm.
- kubeVersion >=1.33.0-0.

## Image
- repository: `ghcr.io/mintplex-labs/anything-llm`
- tag: `latest@sha256:98da7eaf1dcac3bc684556c340eeec69a056dc6d0133795d65c0189a5332e42a` (rolling tag, digest pinned in chart)
- pullPolicy: IfNotPresent

## Security context (chart defaults)
- readOnlyRootFilesystem: false
- runAsUser: 0, runAsGroup: 0 (root in chart)
- capabilities add: SYS_ADMIN

## Ports
- service.main.ports.main: protocol http, port 3001.

## Env (chart)
| Env | Value |
| --- | --- |
| SERVER_PORT | `{{ .Values.service.main.ports.main.port }}` (3001) |
| STORAGE_DIR | `{{ .Values.persistence.storage.mountPath }}` (/app/server/storage) |
| JWT_SECRET | secretKeyRef `anythinglmm-secrets` key `JWT_SECRET` (from `anythingLlm.jwtSecret`, placeholder, must be changed) |
| PASSWORDMINCHAR | 8 |
| PASSWORDMAXCHAR | 250 |
| PASSWORDLOWERCASE / UPPERCASE / NUMERIC / SYMBOL | 1 each |
| PASSWORDREQUIREMENTS | 4 |

Commented-out examples only (provider keys, VECTOR_DB, AUTH_TOKEN, DISABLE_TELEMETRY). Not set by chart.

## Persistence
| Name | mountPath |
| --- | --- |
| storage | /app/server/storage |
| hotdir | /app/collector/hotdir |
| outputs | /app/collector/outputs |

## Gotchas
- Chart runs as UID/GID 0 with SYS_ADMIN. The container build must run as `USER anythingllm` (see github file).
- Chart's JWT secret is a placeholder ("must be changed").
