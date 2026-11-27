# TrueCharts chart: booklore

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/booklore/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `booklore` v7.0.0, `appVersion: 2.4.0`, category `media`, train `stable`.
- Description: self-hosted multi-user digital library (smart shelves, auto metadata, Kobo and KOReader sync, BookDrop imports, OPDS, built-in reader for EPUB, PDF, comics).
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Chart dependency: `mariadb` (enabled, depconfig `mariadbUsername: booklore`).
- Sources: `ghcr.io/booklore-app/booklore`, github booklore-app/booklore, trueforge chart path.

## Image (values.yaml)
- Repository: `ghcr.io/booklore-app/booklore`
- Tag: `v2.4.0@sha256:f92dae443c38098bf8348742465f6f3b17b619cb8f0e5c2cf195dcdfbb88eaeb`
- pullPolicy: IfNotPresent

## Security context
- `readOnlyRootFilesystem: false`, `runAsGroup: 0`, `runAsUser: 0`.

## Ports
| Name | Port | Protocol | Note |
| --- | --- | --- | --- |
| main | 6060 | http | `BOOKLORE_PORT` set from this value |

## Env (workload.main.podSpec.containers.main.env)
| Var | Source |
| --- | --- |
| DATABASE_URL | secretKeyRef `{{Release.Name}}-mariadbcreds` key `jdbc-mariadb` |
| DATABASE_USERNAME | `dependencies.mariadb.depconfig.mariadbUsername` (booklore) |
| DATABASE_PASSWORD | secretKeyRef `{{Release.Name}}-mariadbcreds` key `mariadb-password` |
| BOOKLORE_PORT | `service.main.ports.main.port` (6060) |

## Persistence
| Name | Mount | Note |
| --- | --- | --- |
| data | /app/data | enabled |
| bookdrop | /bookdrop | enabled |
| varrun | (none) | disabled |

## Probes
- Not set in values.yaml.

## Gotchas
- Requires external MariaDB (chart dependency). Chart runs as root.
- Chart DB username is `booklore`; upstream application.yaml default is `root` (`${DATABASE_USERNAME:root}`).
