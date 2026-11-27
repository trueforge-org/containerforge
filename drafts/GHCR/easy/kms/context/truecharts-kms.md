# TrueCharts kms (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kms/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kms/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `kms` v24.0.0, appVersion `minimal`. "Private Windows Activation Server for development and testing".
- Depends on `common`. Keywords: kms.
- Chart sources: ghcr.io/py-kms-organization/py-kms, github.com/Py-KMS-Organization/py-kms.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/py-kms-organization/py-kms` |
| tag | `minimal@sha256:d6e0989ae210c203c8e0d56638344219a5e5f27d088e816b910b6fdde935dd8c` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Ports

| Name | Port | Target | Protocol |
| --- | --- | --- | --- |
| main | 1688 | 1688 | tcp (default protocol, not set) |

## Env

- No env vars set in values.yaml (chart relies on upstream image defaults).

## Volumes / paths

- None declared in values.yaml.

## User / UID

- `securityContext.container`: `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Probes

- liveness, startup, readiness: all `type: tcp`.

## Gotchas

- Chart runs as root; upstream image creates user `py-kms` (see py-kms-upstream-dockerfile-startpy.md).
