# TrueCharts chart: etherpad

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/etherpad/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `etherpad` v24.0.0, `appVersion: 3.3.22`, category media, train stable.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts) and a bundled postgresql dependency.
- Chart sources listed: etherpad.org, ghcr.io/ether/etherpad, github.com/ether/etherpad-lite.

## Image
- repository: `ghcr.io/ether/etherpad` (GHCR, not Docker Hub)
- tag: `3.3.22@sha256:a6c5adbdf315beac5062e01059fd3021f2f790bfaf1669372a72bb300527b323`

## Ports
- service main: port 10060 -> targetPort 9001 (container listens on 9001)

## Env vars (values.yaml, workload main)
| Name | Value in chart | Note |
| --- | --- | --- |
| DB_TYPE | postgres | |
| DB_NAME | from postgresql depconfig (`etherpad`) | |
| DB_USER | from postgresql depconfig (`etherpad`) | |
| DB_PORT | 5432 | |
| DB_PASS | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` | |
| DB_HOST | secretKeyRef `<release>-postgresqlcreds` key `plainhost` | |
| TITLE | Etherpad | |
| FAVICON | favicon.ico | |
| DEFAULT_PAD_TEXT | Welcome text (long string) | |
| ADMIN_PASSWORD | secretKeyRef `env-secrets` key ADMIN_PASSWORD | chart default `adminpass` |
| USER_PASSWORD | secretKeyRef `env-secrets` key USER_PASSWORD | chart default `firstuserpass` |

## Volumes/paths
- persistence `data`: mountPath `/opt/etherpad-lite/var`

## User/UID
- chart securityContext: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false (chart runs as root; upstream image runs as etherpad)

## Gotchas
- Chart hard-codes DB as postgres; the upstream image default is `dirty` (file DB).
