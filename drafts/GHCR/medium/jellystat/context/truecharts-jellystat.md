# TrueCharts chart: jellystat

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/jellystat/values.yaml, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/jellystat/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart description: "A free and open source Statistics App for Jellyfin."
- Chart version 9.0.0, `appVersion: latest`, library dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Upstream sources listed: ghcr.io/cyfershepard/jellystat, github.com/CyferShepard/Jellystat.

## Image
- Repository: `ghcr.io/cyfershepard/jellystat`
- Tag: `latest@sha256:e61c759ec706da378bc8374e797da1dfd298ab30f804cefd82d192c301a888c7` (chart pins digest on `latest`)
- securityContext: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Ports
| Name | Chart port | Target | Protocol |
| --- | --- | --- | --- |
| main | 10681 | 3000 | http |
| ws | 10682 | 3004 | tcp |

- Chart comment: "PORT variables do not work" (PORT / WS_PORT env not used).

## Env vars (chart)
| Name | Value |
| --- | --- |
| POSTGRES_USER | from dependency `postgresql.depconfig.postgresqlUsername` (`jfstat`) |
| POSTGRES_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |
| POSTGRES_IP | secretKeyRef `<release>-postgresqlcreds` key `plainhost` |
| POSTGRES_PORT | 5432 |
| JWT_SECRET | secretKeyRef `jellystat-secrets` key `JWT_SECRET` |

- `jellystat.jwtSecret` placeholder: "Must be changed. Random string, at least 32 characters."

## Probes
- liveness, readiness, startup: HTTP path `/`

## Persistence
- `backup`: mountPath `/app/backend/backup-data`

## Dependencies
- postgresql enabled; depconfig user `jfstat`, database `jfstat`.

## Gotchas
- Chart runs as root (runAsUser 0), no read-only rootfs.
- Chart `values.yaml` header: `# yaml-language-server: $schema=./values.schema.json`.
