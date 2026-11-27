# TrueCharts chart: hammond

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hammond/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hammond/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart for Hammond, a self-hosted vehicle expense tracker (fuel and other costs, multi-user). Chart.yaml read; no separate description needed beyond values.

## Image
- `repository: ghcr.io/alfhou/hammond`
- `tag: v0.0.24@sha256:c85dc0293aa10be15280277bade9cce808be572d0d4c5eac62acd87dec30479d`
- `pullPolicy: IfNotPresent`

## Env vars (chart)
| Name | Chart value |
| --- | --- |
| JWT_SECRET | secretKeyRef `secrets`/`JWT_SECRET` |
| CONFIG | `/config` (persistence.config.mountPath) |
| DATA | `/assets` (persistence.assets.mountPath) |

- Chart value `hammond.jwtSecret: "PLACEHOLDERJWTSECRET00000000000000"` (not used by the env block shown).

## Ports
- Service `main`: port 10186, targetPort 3000.

## Volumes/paths
- `persistence.config` enabled -> `/config`.
- `persistence.assets` enabled -> `/assets`.

## User/UID
- Chart does not set securityContext in values. Upstream image has no USER (root).

## Config files
- None in chart. Upstream uses `/config` (CONFIG) and `/assets` (DATA).

## Healthcheck
- None set in chart.

## Gotchas
- Chart values reference a `secrets` secretKeyRef for JWT_SECRET; no `secret:` block is defined in values.yaml. Check the common chart's behaviour for `secrets` before relying on it.
- Chart uses `PLACEHOLDERJWTSECRET...` in `hammond.jwtSecret`; upstream README says change the JWT secret.
