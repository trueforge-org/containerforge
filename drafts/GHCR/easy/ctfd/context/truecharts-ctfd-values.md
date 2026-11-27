# TrueCharts ctfd values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ctfd/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ctfd/ctfd`, pullPolicy IfNotPresent
- tag: `3.8.9@sha256:84aff1e50b6a6f931b5da90c6f5b7c623ba4583217a9b00e9d4c1b7c53b9739f`

## Service / ports
| Name | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 10613 (chart service) | http | 8000 (targetPort) |

## Env vars (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| UPLOAD_PROVIDER | `filesystem` |
| UPLOAD_FOLDER | `{{ persistence.uploads.mountPath }}` = `/uploads` |
| LOG_FOLDER | `{{ persistence.logs.mountPath }}` = `/logs` |
| SECRET_KEY | secretKeyRef `ctfd-secrets` / `SECRET_KEY` |
| REDIS_URL | secretKeyRef, name `<release>-valkeycreds`, key `url` |
| MAIL_USEAUTH | `false` |
| MAILFROM_ADDR | `""` |
| MAIL_SERVER | `""` |
| MAIL_PORT | `587` |
| MAIL_USERNAME | `""` |
| MAIL_PASSWORD | secretKeyRef `env-secrets` / `MAIL_PASSWORD` |
| MAIL_TLS | `false` |
| MAIL_SSL | `false` |
| SAFE_MODE | `true` |
| REVERSE_PROXY | `false` |
| OAUTH_CLIENT_ID | `""` |
| OAUTH_CLIENT_SECRET | secretKeyRef `env-secrets` / `OAUTH_CLIENT_SECRET` |

Values also set `ctfd.secretKey` (placeholder, "must be changed").

## Volumes/paths (persistence)
- `uploads` enabled, mountPath `/uploads`
- `logs` enabled, mountPath `/logs`

## Dependencies
- `valkey` subchart enabled (`dependencies.valkey.enabled: true`); provides `REDIS_URL` secret.

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Secrets
- `env-secrets`: `MAIL_PASSWORD: ""`, `OAUTH_CLIENT_SECRET: ""`
- `ctfd-secrets` key `SECRET_KEY` is referenced but not defined in this values file.

## Gotchas
- Chart service port 10613 maps to container 8000. Upstream EXPOSE and bind are 8000.
- Chart sets `SAFE_MODE: true` (CTFd skips loading plugins).
