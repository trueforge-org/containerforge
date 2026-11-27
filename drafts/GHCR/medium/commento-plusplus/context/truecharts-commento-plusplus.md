# TrueCharts commento-plusplus (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/commento-plusplus/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Commento++ comments box (chart description). Chart version 17.0.0, appVersion 1.8.7. Category media.
- Dependency common 32.8.5 (oci://oci.trueforge.org/truecharts). Kube >=1.33.0-0.

## Image
- repository: ghcr.io/souramoo/commentoplusplus
- tag: v1.8.7@sha256:f3233882b3bd27378eaa6e25b0ffecbb450e2cb2f003c5ae8fd8d80e3bbbdbfe
- pullPolicy: IfNotPresent

## Ports
| Name | port | protocol |
| --- | --- | --- |
| main | 10240 | http |

## Probes
- liveness, readiness, startup: all `type: tcp`.

## Env (container main)
| Name | Value |
| --- | --- |
| COMMENTO_PORT | `{{ service.main.ports.main.port }}` (= 10240) |
| COMMENTO_FORBID_NEW_OWNERS | false |
| COMMENTO_GZIP_STATIC | true |
| COMMENTO_ORIGIN | http://localhost:8080 (chart default, user should set) |
| COMMENTO_ENABLE_WILDCARDS | true |
| COMMENTO_ENABLE_LOGGING | false |
| SMTP_SKIP_HOST_VERIFY | false |
| COMMENTO_SMTP_USERNAME | "" |
| COMMENTO_SMTP_PASSWORD | secretKeyRef env-secrets |
| COMMENTO_SMTP_HOST | "" |
| COMMENTO_SMTP_FROM_ADDRESS | "" |
| COMMENTO_SMTP_PORT | 587 |
| COMMENTO_POSTGRES | secretKeyRef `<Release>-postgresqlcreds` key `url` |

## Dependencies
- postgresql subchart enabled; depconfig postgresqlUsername=comment-plusplus, postgresqlDatabase=comment-plusplus.
- Secret env-secrets: COMMENTO_SMTP_PASSWORD="".

## Gotchas
- COMMENTO_ORIGIN default `http://localhost:8080` conflicts with service port 10240 (chart default, not a fetch-proven error).
- Upstream README says env COMMENTO_PORT default example 8080; chart overrides to 10240.
