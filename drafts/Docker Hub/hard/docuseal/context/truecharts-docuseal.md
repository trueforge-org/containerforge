# TrueCharts chart: docuseal

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/docuseal (directory not fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docuseal/values.yaml
- Fetched 2026-11-26

## Container image (values.yaml)
- `docker.io/docuseal/docuseal`, tag `3.4.0@sha256:b664cc84014f607f090140973f2e082cc551954d42f6f17e07fdd54dee6fdc08`, pullPolicy IfNotPresent. The draft's `3.3.8` is stale for the chart.

## Service
- `service.main.ports.main`: port 10310, protocol http, targetPort 3000.

## Persistence
- `data`: mountPath `/data`, enabled, no type.

## Security context
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0. No podSecurityContext, privileged, allowPrivilegeEscalation or fsGroup set.

## Env vars
- `DATABASE_URL` from secret `{{ .Release.Name }}-postgresqlcreds`, key `url`. No other env vars.

## Probes
- liveness, readiness, startup: type http, path `/`.

## Dependencies
- `postgresql` enabled; depconfig postgresqlUsername `docuseal`, postgresqlDatabase `docuseal`.
