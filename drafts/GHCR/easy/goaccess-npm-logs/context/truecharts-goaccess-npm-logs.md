# TrueCharts goaccess-npm-logs (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/goaccess-npm-logs/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/goaccess-npm-logs/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `goaccess-npm-logs` v11.0.1, appVersion `latest`. "GoAccess for Nginx Proxy Manager Logs". Category Tools-Utilities.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Chart sources: ghcr.io/xavier-hernandez/goaccess-for-nginxproxymanager, xavier-hernandez/goaccess-for-nginxproxymanager.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/xavier-hernandez/goaccess-for-nginxproxymanager` |
| tag | `latest@sha256:0c59bfe66c861352d1c87b14a772bf361fec1f544e0d73a2e017c2d4a650c430` |
| pullPolicy | IfNotPresent |

- Third-party GHCR image (not Docker Hub). No Docker Hub page applicable.

## Ports

| Name | Container | Service port | Protocol |
| --- | --- | --- | --- |
| main | 7880 | 7880 | tcp |

## Volumes / paths

| Name | Mount | Notes |
| --- | --- | --- |
| hostpath1 | `/opt/log` | hostPath, readOnly: true |

## Env (chart-provided)

| Key | Value |
| --- | --- |
| BASIC_AUTH | `"True"` |
| BASIC_AUTH_USERNAME | `x` |
| BASIC_AUTH_PASSWORD | from secret `env-secrets` key `BASIC_AUTH_PASSWORD` |
| DEBUG | `"False"` |
| EXCLUDE_IPS | `""` |
| SKIP_ARCHIVED_LOGS | `"False"` |

- Chart secret `env-secrets` has a placeholder password value (not recorded).

## User / UID

- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Healthcheck / probes

- None set in values.yaml.

## Gotchas

- Chart runs as root with writable rootfs; the ContainerForge plan runs as non-root `apps` (see plan.md).
- Chart sets BASIC_AUTH env vars; the plan does not implement basic auth.
